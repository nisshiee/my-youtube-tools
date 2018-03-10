require 'set'

require_relative '../discord'

class YoutubeTools::Discord::Interviewer
  require_relative './interviewer/air_reader'

  # @param [#speak] microphone
  def initialize(microphone:)
    @microphone = microphone
    @air_reader = AirReader.new
    @participants = Set.new
  end

  def run
    @air_reader.on_need_interview do
      next if @participants.empty?
      @microphone.speak(random_interview)
    end
    @air_reader.run
  end

  def receive_reply(user:, speaking:)
    @participants << user

    signal = AirReader::Signal.new.tap do |s|
      s.user = user
      s.speaking = speaking
    end
    @air_reader.push(signal: signal)
  end

  def bye_user(user)
    @participants.delete(user)
    @air_reader.bye_user(user)
  end

  private

  def random_interview
    @idx = @idx ? @idx + 1 : 0
    if @idx < DEMO_CANDIDATES.length
      DEMO_CANDIDATES[@idx]
    else
      interview_candidates.sample
    end
  end

  DEMO_CANDIDATES = [
    # "にっしーさん、今なにしてるの〜？",
    # "いいださん、すぴー会議への意気込みを！",
    # "いいださん、今注目してるゲームはありますか？",
    # "にっしーさん、今日のイチオシを教えて！",
  ].freeze

  def interview_candidates
    candidates = [
      '何かしゃべって〜〜〜'
    ]

    @participants.each do |participant|
      candidates << "#{participant.nickname}さん、今なにしてるの〜？"
      candidates << "#{participant.nickname}さん、今日のイチオシを教えて！"
    end

    candidates
  end

  class << self
    def start
      EventMachine.run do
        gateway = YoutubeTools::Discord::Client::Gateway.new
        gateway.run

        mic = Class.new do
          def initialize
            @client = YoutubeTools::Discord::Client::Rest.new
          end
          def speak(msg)
            @client.send_message(msg)
          end
        end.new
        interviewer = new(microphone: mic)

        gateway.on_connect_voice do |v|
          v.on_speaking do |uid, speaking|
            user = YoutubeTools::Discord::User.find(uid)
            next unless user
            interviewer.receive_reply(user: user, speaking: speaking)
          end
          v.on_user_exit do |uid|
            user = YoutubeTools::Discord::User.find(uid)
            next unless user
            interviewer.bye_user(user)
          end
          v.run
          interviewer.run
        end
        gateway.connect_voice
      end
    end
  end
end
