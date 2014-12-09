FactoryGirl.define do
  factory :docker_repository do
    sequence(:name) { |n| "repository#{n}" }
    association :registry, :factory => :docker_registry
  end
end
