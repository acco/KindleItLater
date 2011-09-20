class User < ActiveRecord::Base
  authenticates_with_sorcery!
  has_many :accounts
  
  attr_accessible :email, :password, :password_confirmation
  
  validates_associated :accounts
  validates_confirmation_of :password
  validates_presence_of :password, :on => :create
  validates_presence_of :kindle
  validates :email,   :uniqueness => true, 
                      :length => { :within => 5..50 },
                      :format => { :with => /^[^@][\w._%+-]+@[\w.-]+[.][a-z]{2,4}$/i}
  validates :kindle,  :uniqueness => true, 
                      :length => { :within => 5..50 },
                      :format => { :with => /^[^@][\w._%+-]+@free\.kindle\.com$/i}
  validate :kindle_email_must_be_valid
  
  # Virtual attribute, prefix of the kindle email address
  def kindle_email
    self.kindle.split('@')[0] if kindle
  end
  
  def kindle_email=(kindle_email)
    # Remove suffix in case it was entered
    k = kindle_email.split('@')[0]
    self.kindle = "#{k}@free.kindle.com"
  end
  
  private
  
  def kindle_email_must_be_valid
    unless kindle_email && self.kindle_email.match(/^[\w._%+-]+\w$/)
      errors.add(:kindle_email, "must be a valid Kindle address")
    end
  end
end
