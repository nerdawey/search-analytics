class SearchEvent < ApplicationRecord
  validates :user_hash, presence: true
  validates :session_id, presence: true
  validates :raw_value, presence: true
  validates :event_type, presence: true, inclusion: { in: %w[keystroke finalize] }

  scope :recent, -> { order(created_at: :desc) }
  scope :by_user, ->(user_hash) { where(user_hash: user_hash) }
  scope :by_session, ->(session_id) { where(session_id: session_id) }
  scope :keystrokes, -> { where(event_type: 'keystroke') }
  scope :finalized, -> { where(event_type: 'finalize') }

  def self.create_keystroke(user_hash:, session_id:, raw_value:)
    create!(
      user_hash: user_hash,
      session_id: session_id,
      raw_value: raw_value,
      event_type: 'keystroke'
    )
  end

  def self.create_finalize(user_hash:, session_id:, raw_value:)
    create!(
      user_hash: user_hash,
      session_id: session_id,
      raw_value: raw_value,
      event_type: 'finalize'
    )
  end
end
