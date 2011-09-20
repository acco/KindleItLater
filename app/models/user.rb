class User < ActiveRecord::Base
  authenticates_with_sorcery!
  has_many :accounts
  
  attr_accessible :email, :password, :password_confirmation
  
  validates_confirmation_of :password
  validates_presence_of :password, :on => :create
  validates :email, :uniqueness => true, 
                    :length => { :within => 5..50 },
                    :format => { :with => /^[^@][\w._%+-]+@[\w.-]+[.][a-z]{2,4}$/i}
end
