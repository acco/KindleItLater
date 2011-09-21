class Account < ActiveRecord::Base
  include RILHelper
  belongs_to :user
  has_many :line_items, :dependent => :destroy
  before_save :set_last_retrieve
  
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
    # Prevent unauthenticated accounts from retrieving
    if self.auth
      response = ril_request(:retrieve, {:name => self.name, :password => self.password, :since => self.last_retrieve.to_i})
      items = self.check_response(response)
      # Check that we got a hash response, there's a list, and status = 1 (changes available)
      if items.class == Hash && items['list'] && items['status'] == 1
        items['list'].each_value do |item|
          # Protect against a bad response
          if item['item_id']
            # Protect against duplicate entries
            match = LineItem.where(:account_id => self.id, :item_id => item['item_id']).first
            if match
              # Update an entry if it already exists
              # This probably won't matter--we should only want to send new items to a kindle
              match.url = item['url']
              match.title = item['title']
              match.save
            else
              LineItem.create(:account_id => self.id, :item_id => item['item_id'].to_i, :title => item['title'], :url => item['url'])
            end
          end
        end
      end
      self.last_retrieve = Time.now
    end
  end
  
  def check_response(response)
    r = ActiveSupport::JSON.decode(response)
    if r.class == String
      if response.include?("200")
        true
      elsif response.include?("401")
        errors.add(:name, "could not authenticate with ReadItLater")
        self.auth = false
      else
        errors.add(:base, "Error contacting ReadItLater servers. Please try again later")
      end
    else
      r
    end
  end
  
  def authenticate_with_read_it_later
    self.auth = true if self.check_response(ril_request(:auth, {:name => self.name, :password => self.password}))
  end
  
  private
  
  def set_last_retrieve
    self.last_retrieve ||= Time.now
  end
end
