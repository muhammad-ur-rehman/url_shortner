class ApplicationController < ActionController::API
  include Respondable
  rescue_from StandardError, with: :handle_internal_server_error
  before_action :authenticate_user

  private

  def authenticate_user
    token = request.headers['Authorization']&.split&.last
    decoded_token = Jwt::Decode.decode(token)

    if decoded_token
      @current_user = User.find(decoded_token.symbolize_keys[:user_id])
    else
      render_unauthorized({ error: 'Unauthorized' })
    end
  end

  def handle_internal_server_error(exception)
    Rails.logger.error(exception.message)
    Rails.logger.error(exception.backtrace.join("\n"))

    render_internal_server({ errors: [exception.message] })
  end
end
