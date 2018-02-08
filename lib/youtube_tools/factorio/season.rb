require_relative '../factorio'

class YoutubeTools::Factorio::Season
  attr_accessor :name, :order, :playlist_url, :private

  def initialize(name:, order:, playlist_url:, private: false)
    self.name = name
    self.order = order
    self.playlist_url = playlist_url
    self.private = private
  end

  def default_description
    @default_description ||= begin
      other_lists = YoutubeTools::Factorio::Season.all.select do |s|
        next false if s == self
        next false if s.private && !self.private
        true
      end
      other_lists = other_lists.map { |s| "  #{s.name}\n      #{s.playlist_url}" }
      other_lists = other_lists.join("\n")

      <<~DESC
        #{name}
        再生リスト: #{playlist_url}

        Factorio: https://www.factorio.com/

        他のFactorioシリーズ
        #{other_lists}
      DESC
    end
  end

  SEASON_1 = new(
    name: '業務日報', order: 1, private: true,
    playlist_url: ENV['SEASON_1_URL'],
  )
  SEASON_2 = new(
    name: 'Factorio業務日報 Season2', order: 2,
    playlist_url: 'https://www.youtube.com/playlist?list=PLKeRpiqlb0qpI9mu5KisNQLkrSxnCPtbQ',
  )
  SEASON_3 = new(
    name: 'ITエンジニアと遊ぶFactorioマルチプレイ Season3', order: 3,
    playlist_url: 'https://www.youtube.com/playlist?list=PLKeRpiqlb0qqos2pdYTxiF9Ld7NYHE6tX',
  )
  SEASON_4 = new(
    name: 'ITエンジニアと遊ぶFactorioマルチプレイ Season4', order: 4,
    playlist_url: 'https://www.youtube.com/playlist?list=PLKeRpiqlb0qpCkQGRdN3gLio2x6-YSbkv',
  )

  def self.all
    [
      SEASON_1,
      SEASON_2,
      SEASON_3,
      SEASON_4,
    ]
  end

  def self.detect_by_video_title(title)
    case title
    when /\A業務日報 \d{4}-\d{2}-\d{2}/
      SEASON_1
    when /\AFactorio業務日報 Season2 \d{4}-\d{2}-\d{2}/
      SEASON_2
    when /\AITエンジニアと遊ぶFactorioマルチプレイ Season3 \d{4}-\d{2}-\d{2}/
      SEASON_3
    when /\AITエンジニアと遊ぶFactorioマルチプレイ Season4 \d{4}-\d{2}-\d{2}/
      SEASON_4
    end
  end
end
