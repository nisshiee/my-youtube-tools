require_relative '../factorio'
require_relative './video'

class YoutubeTools::Factorio::DescriptionUpdator
  def run
    YoutubeTools::Factorio::Video.all.each do |v|
      $stdout.puts <<~MESSAGE
        #{v.title}
          https://www.youtube.com/watch?v=#{v.id}

      MESSAGE

      v.update_description(v.season.default_description)
    end
  end
end
