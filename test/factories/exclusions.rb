# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :exclusion do
    association :option
    association :excluded_option, :factory => :option
  end
end
