require 'spec_helper'

describe Account do
  before(:each) do
    # Circumvent readitlater authentication
    Account.any_instance.stub(:authenticate_with_read_it_later).and_return(true)
  end
  
  it "should reject an invalid read it later account name" do
    ["in valid", "has%symbols", "$is_symboly", ""].each do |test|
      account = Factory.build(:account, :name => test)
      account.save
      Account.should have(0).record
    end
  end
  
  it "should associate with a user" do
    user = Factory.create(:user)
    account = Factory.create(:account, :user => user)
    user.reload
    user.accounts[0].should == account
  end
  
  it "should halt save if not an authentic read it later account" do
    account = Factory.build(:account, :name => 'thisisfalse', :password => 'test234')
    Account.any_instance.unstub(:authenticate_with_read_it_later)
    account.save
    Account.should have(0).record
  end
  
  it "should save if authenticated by read it later" do
    account = Factory.build(:account, :name => 'name')
    Account.any_instance.unstub(:authenticate_with_read_it_later)
    account.save
    Account.should have(1).record
  end
      
  it "should be forced to associate with a user" do
    account = Factory.build(:account, :user => nil)
    account.save
    Account.should have(0).record
  end
  
  it "should get line_items for an account" do 
    account = Factory.create(:account, :name => "name")
    account.retrieve_items
    LineItem.should have(7).record
  end
  
  it "should not get duplicate line_items for an account" do
    account = Factory.create(:account, :name => "name")
    account.retrieve_items
    account.retrieve_items
    LineItem.should have(7).record
  end
end
