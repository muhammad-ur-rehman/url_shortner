module UrlValidatable
  extend ActiveSupport::Concern
  include Respondable

  included do
    before_action :validate_url_expires_at, only: [:create]
  end

  private

  def validate_url_expires_at
    return unless params[:url] && params[:url][:expires_at]

    begin
      DateTime.parse(params[:url][:expires_at].to_s)
    rescue ArgumentError
      render_unprocessable_entity(["Expires at must be a valid ISO 8601 datetime format (e.g., '2025-01-19 00:00:00')"])
      return
    end

    return unless params[:url][:expires_at].to_time < Time.current

    render_unprocessable_entity(['expires_at must be in the future'])
  end
end
