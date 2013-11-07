require 'time'

class Mws::Query

  def initialize overrides
    options = {
      signature_method: 'HmacSHA256',
      signature_version: '2',
      timestamp: Time.now.iso8601
    }.merge overrides

    options[:aws_access_key_id] ||= options.delete :access
    options[:seller_id] ||= options.delete(:merchant) || options.delete(:seller)
    options[:marketplace_id_list] ||= options.delete(:markets) || options.delete(:market) || []

    @params = Mws::Utils::format_params options
  end

  def to_s
    @params.map { |pair| pair.join '=' }.join '&'
  end
end
