require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'google/apis/youtube_v3'

module YoutubeTools
  OAUTH_SCOPE = %w[
    https://www.googleapis.com/auth/youtube.upload
    https://www.googleapis.com/auth/youtube
  ]
  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
  TOKEN_STORE_USER_ID = 'default'

  class << self
    def svc
      @svc ||= Google::Apis::YoutubeV3::YouTubeService.new.tap do |cli|
        cli.authorization = user_credentials
      end
    end

    private

    def user_credentials
      client_id = Google::Auth::ClientId.new(ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'])
      token_store = Google::Auth::Stores::FileTokenStore.new(file: 'tmp/token_store')
      authorizer = Google::Auth::UserAuthorizer.new(client_id, OAUTH_SCOPE, token_store)

      credentials = authorizer.get_credentials(TOKEN_STORE_USER_ID)
      if credentials.nil?
        url = authorizer.get_authorization_url(base_url: OOB_URI)
        $stdout.write <<~MESSAGE.chomp + ' '
          以下のURLをブラウザで開いて、認証コードを入力してください

          #{url}

          認証コード:
        MESSAGE
        $stdout.flush
        code = $stdin.gets.chomp

        credentials = authorizer.get_and_store_credentials_from_code(
          user_id: TOKEN_STORE_USER_ID,
          code: code,
          base_url: OOB_URI
        )
      end
      credentials
    end
  end
end
