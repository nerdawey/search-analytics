FactoryBot.define do
  factory :search_event do
    user_hash { "user_#{SecureRandom.hex(8)}" }
    session_id { "session_#{SecureRandom.hex(8)}" }
    raw_value { 'test search term' }
    event_type { 'keystroke' }
  end
end
