require 'spec_helper'

describe Account do
  before(:each) do
    # Circumvent readitlater authentication
    Account.any_instance.stub(:authenticate_with_read_it_later).and_return(true)
    # If not stubbed, won't fetch past RIL items
    Account.any_instance.stub(:last_retrieve).and_return(Time.parse("June 2000"))
  end
  
  it "should reject an invalid read it later account name" do
    ["in valid", "has%symbols", "$is_symboly", ""].each do |test|
      account = Factory.build(:account, :name => test, :auth => false)
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
    account = Factory.build(:account, :name => 'thisisfalse', :password => 'test234', :auth => false)
    Account.any_instance.unstub(:authenticate_with_read_it_later)
    account.save
    Account.should have(0).record
  end
  
  it "should save if authenticated by read it later" do
    account = Factory.build(:account, :name => 'name', :auth => false)
    Account.any_instance.unstub(:authenticate_with_read_it_later)
    account.save
    Account.should have(1).record
    account.auth.should be_true
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
  
  it "should set last_retrieve upon creation to current datetime" do
    Account.any_instance.unstub(:last_retrieve)
    account = Factory.create(:account, :last_retrieve => nil)
    account.last_retrieve.should be_a_kind_of(Time)
  end
  
  it "should be able to handle a bad request" do
    account = Factory.create(:account)
    account.retrieve_items
    account.errors[:name].should eql(["could not authenticate with ReadItLater"])
  end
  
  it "should un-authenticate user if they yield a bad request" do
    account = Factory.create(:account)
    account.retrieve_items
    account.auth.should be_false
  end
  
  it "should not fetch any items if recently retrieved" do
    Account.any_instance.unstub(:last_retrieve)
    account = Factory.create(:account, :name => "name")
    account.last_retrieve = Time.now
    account.retrieve_items
    LineItem.should have(0).record
  end
  
  it "should not fetch any items past last_retrieve" do
    Account.any_instance.unstub(:last_retrieve)
    account = Factory.create(:account, :name => "name")
    account.last_retrieve = Time.at(1312795380)
    account.retrieve_items
    LineItem.should have(1).record
  end
  
  it "should not retrieve any items if account has not been authenticated" do
    account = Factory.create(:account, :name => "name", :auth => false)
    account.retrieve_items
    LineItem.should have(0).record
  end
  
  it "should set last_retrieve to current time after fetching items" do
    Account.any_instance.unstub(:last_retrieve)
    Timecop.freeze(t = Time.now) do
      account = Factory.create(:account, :name => "name", :last_retrieve => Time.parse("June 2000"))
      account.retrieve_items
      LineItem.should have(7).records
      account.last_retrieve.should eql(t)
    end
  end
  
  it "should update a duplicate entry" do
    h = {'status' => 1, 'list' => {'101' => {'item_id' => '101', 'url' => 'http://url.first.com' }}}
    account = Factory.create(:account)
    account.stub(:check_response).and_return(h)
    account.retrieve_items
    LineItem.should have(1).records
    h = {'status' => 1, 'list' => {'101' => {'item_id' => '101', 'url' => 'http://url.second.com' }}}
    account.unstub(:check_response)
    account.stub(:check_response).and_return(h)
    account.retrieve_items
    account.line_items.first.url.should eql("http://url.second.com")
  end 
end
