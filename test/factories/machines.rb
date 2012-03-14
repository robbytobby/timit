# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :machine do
    sequence(:name){|n| "Name#{n}"}
    max_duration ""
    description "Text"
    min_booking_time 1
    min_booking_time_unit 'hour'
  end
end
