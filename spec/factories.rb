FactoryGirl.define do
  factory :user do
    password "inthehouse"
    sequence(:email) { |n| "MyEmail#{n}@example.com" }
    sequence(:kindle) { |n| "MyKindle#{n}@free.kindle.com" }
  end
  
  factory :account do
    sequence(:name) {|n| "#{n}name" }
    password "123"
    user
    auth true
  end
  
  factory :line_item do 
    title "title"
    url "http://www.example.com"
    account
    sent false
  end
end