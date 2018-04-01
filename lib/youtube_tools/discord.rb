require 'colorize'
require 'hashie'
require 'json'
require 'signet/oauth_2/client'
require 'websocket-eventmachine-client'

require_relative '../youtube_tools'

module YoutubeTools::Discord
  BOT_TOKEN = ENV['DISCORD_BOT_TOKEN'].dup.freeze
  GUILD_ID = ENV['DISCORD_GUILD_ID'].dup.freeze
  TEXT_CHANNEL_ID = ENV['DISCORD_TEXT_CHANNEL_ID'].dup.freeze
  VOICE_CHANNEL_ID = ENV['DISCORD_VOICE_CHANNEL_ID'].dup.freeze

  require_relative './discord/client'
  require_relative './discord/interviewer'
  require_relative './discord/user'
end
