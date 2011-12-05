# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    first_name "First"
    last_name "Last"
    phone "203-1234"
    sequence(:email){|n| "email#{n}@test.org"}
    password "password"
    password_confirmation "password"
    role "unprivileged"
    factory :approved_user do
      approved true
    end
    factory :admin_user do
      approved true
      role 'admin'
    end
    factory :teaching_user do
      approved true
      role 'teaching'
    end
    factory :unprivileged_user do
      approved true
    end
  end
end
