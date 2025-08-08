class SearchSummary < ApplicationRecord
  validates :user_hash, presence: true
  validates :term, presence: true
  validates :count, presence: true, numericality: { greater_than: 0 }
  validates :last_searched_at, presence: true
  validates :user_hash, uniqueness: { scope: :term }

  scope :recent, -> { order(last_searched_at: :desc) }
  scope :by_user, ->(user_hash) { where(user_hash: user_hash) }
  scope :top_terms, ->(limit = 10) { order(count: :desc).limit(limit) }

  def self.increment_or_create(user_hash:, term:)
    normalized_term = normalize_term(term)
    return if normalized_term.blank?

    summary = find_or_initialize_by(user_hash: user_hash, term: normalized_term)
    if summary.new_record?
      summary.count = 1
      summary.last_searched_at = Time.current
    else
      summary.count += 1
      summary.last_searched_at = Time.current
    end
    summary.save!
    summary
  end

  def self.normalize_term(term)
    return nil if term.blank?

    term.strip.downcase
  end

  def self.top_searches_for_user(user_hash, limit = 10)
    by_user(user_hash).top_terms(limit)
  end

  def self.recent_searches_for_user(user_hash, limit = 10)
    by_user(user_hash).recent.limit(limit)
  end
end
