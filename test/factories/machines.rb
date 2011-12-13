# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :machine do
    sequence(:name){|n| "Name#{n}"}
    max_duration ""
    description "Text"
  end
end
