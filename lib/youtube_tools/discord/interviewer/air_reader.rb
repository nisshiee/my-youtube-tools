require 'eventmachine'

class YoutubeTools::Discord::Interviewer::AirReader
  JUDGE_INTERVAL = 10
  JUDGE_RATIO = 0.5
  DEFAULT_SCORE = 20

  def on_need_interview(&block)
    @on_need_interview = block
  end

  def run
    @speaking_signals = {}
    @speaking_histories = {}
    @conversation_score = DEFAULT_SCORE
    EventMachine.add_periodic_timer(1) do
      tick
    end
  end

  # @param [YoutubeTools::Discord::Interviewer::AirReader::Signal] signal
  def push(signal:)
    @speaking_signals[signal.user] = signal.speaking
  end

  def bye_user(user)
    @speaking_signals.delete(user)
  end

  private

  def tick
    someone_speaking = false

    @speaking_signals.each do |user, speaking|
      history = (@speaking_histories[user] ||= [])
      history.push(speaking)
      history.shift until history.size <= JUDGE_INTERVAL

      next if history.size < JUDGE_INTERVAL

      speaking_signal_num = history.select { |e| e }.size
      speaking_ratio = speaking_signal_num.to_f / history.size
      someone_speaking = true if speaking_ratio >= JUDGE_RATIO
    end

    if someone_speaking
      @conversation_score = DEFAULT_SCORE
    else
      @conversation_score -= 1
      if @conversation_score <= 0
        @on_need_interview&.call
        @conversation_score = DEFAULT_SCORE
      end
    end
    puts "#{@conversation_score}: #{someone_speaking ? 'speaking' : 'stopping'}"
  end

  class Signal
    # @!attribute [rw] user
    #   @return [YoutubeTools::Discord::User]
    # @!attribute [rw] speaking
    #   @return [Boolean]
    attr_accessor :user, :speaking
  end
end
