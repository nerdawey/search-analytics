FactoryBot.define do
  factory :search_summary do
    user_hash { "user_#{SecureRandom.hex(8)}" }
    term { 'test search term' }
    count { 1 }
    last_searched_at { Time.current }
  end
end
