require 'colorize'
require 'hashie'
require 'json'
require 'websocket-eventmachine-client'

require_relative '../client'

class YoutubeTools::Discord::Client::Voice
  def initialize(endpoint:, server_id:, user_id:, session_id:, token:)
    @endpoint   = endpoint
    @server_id  = server_id
    @user_id    = user_id
    @session_id = session_id
    @token      = token
  end

  def run
    @client = WebSocket::EventMachine::Client.connect(uri: @endpoint)

    @client.onopen do
      log_info('Connected')
      identify
    end

    @client.onmessage do |msg, type|
      log_receive(msg)
      msg = JSON.parse(msg, object_class: Hashie::Mash)

      case msg.op
      when 8
        EventMachine.add_periodic_timer(40) do
          heartbeat
        end
      when 5
        break unless @on_speaking
        @on_speaking.call(msg.d.user_id, msg.d.speaking)
      when 13
        break unless @on_user_exit
        @on_user_exit.call(msg.d.user_id)
      end
    end

    @client.onclose do |code, reason|
      log_info("Disconnected with status code: #{code}")
      log_info("  Reason: #{reason}")
      EventMachine.stop_event_loop
    end
  end

  def on_speaking(&block)
    @on_speaking = block
  end

  def on_user_exit(&block)
    @on_user_exit = block
  end

  private

  def identify
    msg = {
      op: 0,
      d:  {
        server_id:  @server_id,
        user_id:    @user_id,
        session_id: @session_id,
        token:      @token,
      },
    }.to_json
    log_send(msg)
    @client.send(msg)
  end

  def heartbeat
    msg = {
      op: 3,
      d:  Time.now.to_i * 1000,
    }.to_json
    log_send(msg)
    @client.send(msg)
  end

  def log(msg, color)
    puts "[Voice] #{msg}".colorize(color)
  end

  def log_info(msg)
    log(msg, :light_green)
  end

  def log_send(msg)
    log(msg, :light_blue)
  end

  def log_receive(msg)
    log(msg, :light_magenta)
  end
end
