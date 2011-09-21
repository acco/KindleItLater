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
end
