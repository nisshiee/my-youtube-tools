require 'faraday'

require_relative '../client'

class YoutubeTools::Discord::Client::Rest
  def initialize
    @client = Faraday.new(url: 'https://discordapp.com') do |f|
      f.request :url_encoded
      f.adapter Faraday.default_adapter

      f.headers['Authorization'] = "Bot #{YoutubeTools::Discord::BOT_TOKEN}"
    end
  end

  def send_message(message)
    @client.post(
      "/api/channels/#{YoutubeTools::Discord::TEXT_CHANNEL_ID}/messages",
      content: message,
    )
  end
end
