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
  end
  
  factory :line_item do 
    url "http://www.example.com"
    account
    sent false
  end
end