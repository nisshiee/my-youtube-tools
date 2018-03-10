require 'colorize'
require 'hashie'
require 'json'
require 'websocket-eventmachine-client'

require_relative '../client'
require_relative './voice'

class YoutubeTools::Discord::Client::Gateway
  def run
    @client = WebSocket::EventMachine::Client.connect(uri: 'wss://gateway.discord.gg')

    @client.onopen do
      log_info('Connected')
    end

    @client.onmessage do |msg, type|
      log_receive(msg)
      msg = JSON.parse(msg, object_class: Hashie::Mash)

      case msg.op
      when 10
        heartbeat
        EventMachine.add_periodic_timer(40) do
          heartbeat
        end
        EventMachine.add_timer(1) do
          identify
        end
      when 0
        case msg.t
        when 'GUILD_CREATE'
          @guild_created = true
        when 'VOICE_STATE_UPDATE'
          @voice_state = msg.d
          start_voice_connection
        when 'VOICE_SERVER_UPDATE'
          @voice_server          = msg.d
          @voice_server.endpoint = "wss://#{@voice_server.endpoint.gsub(/:\d+/, '')}"
          start_voice_connection
        end
      end
    end

    @client.onclose do |code, reason|
      log_info("Disconnected with status code: #{code}")
      log_info("  Reason: #{reason}")
      EventMachine.stop_event_loop
    end
  end

  def on_connect_voice(&block)
    @on_connect_voice = block
  end

  def connect_voice
    if @guild_created
      EventMachine.next_tick do
        voice_state_update
      end
    else
      EventMachine.add_timer(1) do
        connect_voice
      end
    end
  end

  private

  def heartbeat
    msg = '{"op":1,"d":null}'
    log_send(msg)
    @client.send(msg)
  end

  def identify
    msg = {
      op: 2,
      d:  {
        token:      YoutubeTools::Discord::BOT_TOKEN,
        properties: {
          '$os':      'linux',
          '$browser': 'test',
          '$device':  'test',
        },
        presence:   {
          game:   {
            name: 'VTuberSupport',
            type: 0
          },
          status: 'online',
          since:  nil,
          afk:    false
        }
      }
    }.to_json
    log_send(msg)
    @client.send(msg)
  end

  def voice_state_update
    msg = {
      op: 4,
      d:  {
        guild_id:   YoutubeTools::Discord::GUILD_ID,
        channel_id: YoutubeTools::Discord::VOICE_CHANNEL_ID,
        self_mute:  false,
        self_deaf:  false,
      },
    }.to_json
    log_send(msg)
    @client.send(msg)
  end

  def start_voice_connection
    return if @voice
    return unless @on_connect_voice
    return unless @voice_state && @voice_server

    @voice = YoutubeTools::Discord::Client::Voice.new(
      endpoint:   @voice_server.endpoint,
      server_id:  @voice_server.guild_id,
      user_id:    @voice_state.user_id,
      session_id: @voice_state.session_id,
      token:      @voice_server.token,
    )
    @on_connect_voice.call(@voice)
  end

  def log(msg, color)
    puts "[Gateway] #{msg}".colorize(color)
  end

  def log_info(msg)
    log(msg, :green)
  end

  def log_send(msg)
    log(msg, :blue)
  end

  def log_receive(msg)
    log(msg, :magenta)
  end
end
