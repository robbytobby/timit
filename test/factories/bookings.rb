# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :booking do
    sequence(:starts_at){|n| Time.now + n.hours}
    sequence(:ends_at){|n| Time.now + 1.hour + n.hours}
    all_day false
    association :user
    association :machine 
  end
end
