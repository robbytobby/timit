# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :booking do
      starts_at "2011-10-17 17:34:14"
      ends_at "2011-10-17 17:34:14"
      all_day false
      association :user
      association :machine 
    end
end
