FactoryGirl.define do
  factory :docker_tag do
    sequence(:tag) { |n| "tag#{n}" }
    association :repository, :factory => :docker_repository
  end
end
