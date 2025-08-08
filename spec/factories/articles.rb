FactoryBot.define do
  factory :article do
    sequence(:title) { |n| "Article Title #{n}" }
    content { 'This is the content of the article. It contains some text for testing purposes.' }
    published_at { Time.current }
  end
end
