# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :option do
      sequence(:name){|n| "Option-#{n}"}
      association :machine
      association :option_group
    end
end
