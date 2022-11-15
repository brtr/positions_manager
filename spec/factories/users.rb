FactoryBot.define do
  factory :user do
    name { "#{Faker::Name.first_name}" }
    sequence(:email) { |n| "faker#{n}@feedmob.com" }
    password { "abbc1234" }
  end
end
