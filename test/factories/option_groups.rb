# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :option_group do
      name "MyString"
      exclusive false
      optional false
    end
end