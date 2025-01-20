module Respondable
  extend ActiveSupport::Concern

  def render_not_found
    render status: :not_found, json: { errors: { base: I18n.t('activerecord.errors.messages.not_found') } }
  end

  def render_no_content
    render status: :no_content, json: {}
  end

  def render_okay(json_content = {})
    render status: :ok, json: json_content
  end

  def render_created(json_content = {})
    render status: :created, json: json_content
  end

  def render_updated(json_content = {})
    render status: :ok, json: json_content
  end

  def render_unauthorized(json_content = {})
    render status: :unauthorized, json: json_content
  end

  def render_unprocessable_entity(errors = [])
    render status: :unprocessable_entity, json: errors
  end

  def render_conflict(json_content = {})
    render status: :conflict, json: json_content
  end

  def render_bad_request(json_content = {})
    render status: :bad_request, json: json_content
  end

  def render_not_acceptable(json_content = {})
    render status: :not_acceptable, json: json_content
  end

  def render_gone(json_content = {})
    render status: :gone, json: json_content
  end

  def render_internal_server(json_content = {})
    render status: :internal_server_error, json: json_content
  end
end
