FactoryBot.define do
  factory :user do
    name { "Test User" }
    email { Faker::Internet.email }
    password { "password" }
    role { "user" }

    trait :superuser do
      role { "superuser" }
    end
  end
end
