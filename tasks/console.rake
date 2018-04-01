desc '開発用consoleを開始します'
task :console do
  require 'pry'
  require_relative '../lib/youtube_tools'
  require_relative '../lib/youtube_tools/factorio/video'
  require_relative '../lib/youtube_tools/discord'
  require_relative '../lib/youtube_tools/discord/client'
  binding.pry # rubocop:disable Lint/Debugger
end
