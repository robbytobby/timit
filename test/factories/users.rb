# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:email){|n| "email#{n}@test.org"}
    password "password"
    password_confirmation "password"
    factory :approved_user do
      approved true
    end
    factory :admin_user do
      approved true
    end
  end
end
