# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :accessory do
      sequence(:name){|n| "Name#{n}"}
      quantity 1
    end
end
