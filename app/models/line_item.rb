class LineItem < ActiveRecord::Base
  belongs_to :account
  before_save :set_title_if_blank
  
  validates_format_of :url, :with => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix,
                            :presence => true



  private
  
  def set_title_if_blank
    if self.title.nil? || self.title.empty?
      self.title = URI.parse(self.url).host.gsub("www.", "")
    end
  end
end