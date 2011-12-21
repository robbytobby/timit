# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :option_group do
      sequence(:name){|n| "Group-#{n}"}
      exclusive false
      optional false
    end
end
