FactoryBot.define do
  factory :wallet do
    sequence(:name) { |n| "Wallet #{n}" }
    _blockchain { :bitcoin }
    address { '3P3QsMVK89JBNqZQv5zMAKG8FK3kJM4rjt' }
  end
end
