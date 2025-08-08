FactoryBot.define do
  factory :article_view do
    user_hash { SecureRandom.hex(16) }
    association :article
    count { rand(1..10) }
    last_viewed_at { Time.current }
  end
end
