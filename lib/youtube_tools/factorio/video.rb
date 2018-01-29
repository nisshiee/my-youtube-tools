require_relative '../factorio'
require_relative './season'

class YoutubeTools::Factorio::Video
  attr_accessor :id, :title, :season

  def initialize(api_dao: nil, id: nil, title: nil, season:)
    if api_dao
      @api_dao = api_dao
      self.id = api_dao.id
      self.title = api_dao.snippet.title
    else
      self.id = id
      self.title = title
    end

    self.season = season
  end

  def update_description(description)
    return if @api_dao.snippet.description == description
    @api_dao.snippet.description = description
    YoutubeTools.svc.update_video('snippet', @api_dao)
  end

  def self.all
    channel_id = ENV['YOUTUBE_CHANNEL_ID']
    svc = YoutubeTools.svc

    # チャンネル情報を取得し、「そのチャンネルでアップロードされた全動画」プレイリストのIDを取得
    channel = svc.list_channels('contentDetails', id: channel_id).items[0]
    uploads_playlist_id = channel.content_details.related_playlists.uploads

    videos = []
    page_token = nil
    loop do
      # 一覧系API仕様で許容されるmax_result_sizeに依存
      chunk_size = 50

      # プレイリスト内の動画一覧を取得しvideo idリストを作成
      res = svc.list_playlist_items(
        'snippet',
        playlist_id: uploads_playlist_id,
        max_results: chunk_size,
        page_token: page_token,
      )
      video_ids = res.items.map { |pl_item| pl_item.snippet.resource_id.video_id }

      res = svc.list_videos(
        'snippet,status',
        id: video_ids.join(','),
      )

      # Factorio動画のみ抽出してmodel objectを生成
      res.items.each do |item|
        # 「処理済み」でない動画は弾く
        next if item.status.upload_status != 'processed'

        # Factorio動画でない動画は弾く
        season =
          YoutubeTools::Factorio::Season.detect_by_video_title(item.snippet.title)
        next if season.nil?

        # 不要なpartを保持しているとupdateリクエストがコケるので消しておく
        item.status = nil

        videos << new(
          api_dao: item,
          season: season,
        )
      end

      # 一覧取得APIの結果に次ページがある場合は繰り返す
      page_token = res.next_page_token
      break if page_token.nil?
    end

    videos
  end
end
