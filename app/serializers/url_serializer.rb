class UrlSerializer < ActiveModel::Serializer
  attributes :id, :original_url, :key, :click_count, :expires_at, :shortened_url

  def shortened_url
    "#{instance_options[:protocol]}#{instance_options[:url_host]}/short_url?shortened_url=#{object.key}"
  end
end
