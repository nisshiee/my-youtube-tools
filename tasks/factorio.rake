namespace :factorio do
  desc 'Factorio関連動画の説明文を一括更新します'
  task :update_description do
    require_relative '../lib/youtube_tools/factorio/description_updator'
    YoutubeTools::Factorio::DescriptionUpdator.new.run
  end

  desc '話題提供botを起動します'
  task :interviewer do
    require_relative '../lib/youtube_tools/discord/interviewer'
    YoutubeTools::Discord::Interviewer.start
  end
end
