class LineItem < ActiveRecord::Base
  include RILHelper
  belongs_to :account
  before_save :set_title_if_blank
  
  validates_format_of :url, :with => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix,
                            :presence => true

  def body
    # Returns the body of accessed web page
    # Destroys itself if body is too short or a bad request
    body = ril_request(:text, { :url => self.url })
    if body.length < CONFIG['minimum_length']
      self.destroy
    else
      body
    end
  end

  def send_to_kindle
    unless self.sent
      if self.mail
        self.sent = true
      end
    end
  end

  private
  
  def set_title_if_blank
    if self.title.nil? || self.title.empty?
      self.title = URI.parse(self.url).host.gsub("www.", "")
    end
  end
end