desc '開発用consoleを開始します'
task :console do
  require 'pry'
  require_relative '../lib/youtube_tools'
  require_relative '../lib/youtube_tools/factorio/video'
  binding.pry # rubocop:disable Lint/Debugger
end
