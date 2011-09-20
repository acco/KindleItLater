FactoryGirl.define do
  factory :user do
    password "inthehouse"
    sequence(:email) { |n| "MyEmail#{n}@example.com" }
    sequence(:kindle) { |n| "MyKindle#{n}@free.kindle.com" }
  end    
end