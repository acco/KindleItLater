require 'net/https'

class Account < ActiveRecord::Base
  belongs_to :user
  has_many :line_items, :dependent => :destroy
  
  validates :name ,   :uniqueness => true, 
                      :length => { :within => 1..50 },
                      :format => { :with => /^[\w._]+$/i}
  validates_presence_of :password, :user_id
  validate :authenticate_with_read_it_later
  
  def retrieve_items
    # Build a request for line_items to ReadItLater
    # Response is in JSON format
    # Example of a response :
    # {"status":1,"list":{
    # "915":{"item_id":"915","title":"Google","url":"http:\/\/google.com","time_updated":"1312795221","time_added":"1312795221","state":"0"}
    # "since":1316567382,"complete":1}
    response = Account.request(:retrieve, {:name => self.name, :password => self.password})
    items = ActiveSupport::JSON.decode(response)
    # Item id in local databse will match ReadItLater id
    items['list'].each_value do |item|
      # Protect against a bad response
      if item['item_id']
        LineItem.create(:account_id => self.id, :id => item['item_id'].to_i, :title => item['title'], :url => item['url'])
      end
    end      
  end
  
  def authenticate_with_read_it_later
    response = Account.request(:auth, {:name => self.name, :password => self.password})
    if response.include?("200")
      true
    elsif response.include?("401")
      errors.add(:name, "did not authenticate with ReadItLater")
    else
      errors.add(:base, "Error contacting ReadItLater servers. Please try again later")
    end
  end
  
  private

  def Account.request(type, options={})
    case type
    when :retrieve
      url = URI.parse(CONFIG['method_url'] + "get")
      data = "?username=#{options[:name]}&password=#{options[:password]}"
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
    http.request(request).body
  end
end
