# frozen_string_literal: true

module Request
  module SwaggerAccessTokenHelper
    include CurrentUserSpecHelper

    def access_token
      JWT.encode(stubbed_user, ENV['SECRET_KEY_BASE'], 'HS256')
    end
  end
end
