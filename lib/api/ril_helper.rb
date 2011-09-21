require 'net/https'

module RILHelper
  def ril_request(type, options={})
    case type
    when :retrieve
      url = URI.parse(CONFIG['method_url'] + "get")
      data = "?username=#{options[:name]}&password=#{options[:password]}&since=#{options[:since]}"
    when :text
      url = URI.parse(CONFIG['text_method_url'])
      data = "?url=#{options[:url]}"
    when :auth
      url = URI.parse(CONFIG['method_url'] + "auth")
      data = "?username=#{options[:name]}&password=#{options[:password]}"
    end
    data = data + "&apikey=#{CONFIG['read_it_later_api_key']}"
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(url.path + data)
    
    if type == :retrieve
      http.request(request).body
    else
      http.request(request).body
    end
  end
end