FactoryBot.define do
  factory :product do
    name { "Test Product" }
    price { 1000 }
    category # `category` ファクトリとの関連付け
  end
end
