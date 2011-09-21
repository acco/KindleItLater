require 'spec_helper'

describe LineItem do
  before(:each) do
    # Circumvent readitlater authentication
    Account.any_instance.stub(:authenticate_with_read_it_later).and_return(true)
  end
  
  it "should reject a bad url" do
    ["not_valid", "http://sp ace", "bad#url", "this http://badurl.com"].each do |url|
      item = Factory.build(:line_item, :url => url)
      item.save
    end
    LineItem.should have(0).record
  end
  
  it "should accept a good url" do
    accnt = Factory.create(:account)
    ["http://this.fine.com", "http://long.com/test"].each do |url|
      item = Factory.build(:line_item, :url => url, :account => accnt)
      item.save
    end
    LineItem.should have(2).record
  end
  
  it "should set title to URL base if title is blank" do
    item = Factory.build(:line_item, :title => nil, :url => "http://www.nfl.com/some/text/here")
    item.save
    item.reload
    item.title.should eql("nfl.com")
  end
  
  it "should switch to sent when successfully emailed" do
    accnt = Factory.create(:account)
    item = Factory.create(:line_item, :sent => false, :account => accnt)
    item.stub(:mail).and_return(true)
    item.send_to_kindle
    item.sent.should be_true
  end
  
  it "should fetch the body of a webpage" do
    item = Factory.create(:line_item, :url => 'http://en.wikipedia.org/wiki/Ruby_(programming_language)')
    item.body.should match(/Yukihiro Matsumoto/i)
  end
  
  it "should destroy itself if it accesses a bad webpage" do
    item = Factory.create(:line_item, :url => 'http://bad.url.first')
    item.body
    LineItem.should have(0).records
  end
  
  it "should retrieve all pages of a webpage" do
    item = Factory.create(:line_item, :url => 'http://www.theatlantic.com/magazine/archive/2011/10/the-shame-of-college-sports/8643/')
    item.body.should match(/Vaccaro is officially an unpaid consultant to the plaintiffs/)
  end
end
