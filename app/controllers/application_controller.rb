class ApplicationController < ActionController::API
  include Respondable
  rescue_from StandardError, with: :handle_internal_server_error

  private

  def handle_internal_server_error(exception)
    Rails.logger.error(exception.message)
    Rails.logger.error(exception.backtrace.join("\n"))

    render_internal_server({ errors: [exception.message] })
  end
end
