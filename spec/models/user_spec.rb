require 'spec_helper'

describe User do
  it "should create a user" do 
    Factory.create(:user)
    User.should have(1).record
  end
  
  it "should prevent two users with identical emails from signing up" do
    Factory.create(:user, :email => "duplicate@example.com")
    user = Factory.build(:user, :email => "duplicate@example.com")
    user.save
    User.should have(1).record
  end
  
  it "should require a kindle email address" do
    user = Factory.build(:user, :kindle => nil)
    user.save
    User.should have(0).record
  end
  
  it "should require a valid kindle email address" do
    user = Factory.build(:user, :kindle => 'regular_email@example.com')
    user.save
    User.should have(0).record
  end
  
  it "should reject duplicate kindle emails" do 
    Factory.create(:user, :kindle => 'kindle@free.kindle.com')
    user = Factory.build(:user, :kindle => 'kindle@free.kindle.com')
    user.save
    User.should have(1).record
  end
  
  it "should translate kindle_email in form to valid kindle email format" do
    user = Factory.build(:user, :kindle => nil, :kindle_email => 'test')
    user.save
    User.should have(1).record
    user.kindle.should match(/test@free.kindle.com/)
  end
  
  it "should reject an invalid kindle_email from form" do
    ['in valid', 'with$symbols', '()', '#erroneous'].each do |test|
      user = Factory.build(:user, :kindle => nil, :kindle_email => test)
      user.save
      User.should have(0).record
    end
  end
end
