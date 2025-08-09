class ArticleView < ApplicationRecord
  belongs_to :article

  validates :user_hash, presence: true
  validates :count, presence: true, numericality: { greater_than: 0 }
  validates :last_viewed_at, presence: true
  validates :article_id, uniqueness: { scope: :user_hash }

  scope :by_user, ->(user_hash) { where(user_hash: user_hash) }
  scope :recent, -> { order(last_viewed_at: :desc) }
  scope :most_viewed, -> { order(count: :desc) }
  scope :with_articles, -> { includes(:article) }

  def self.increment_or_create(user_hash:, article_id:)
    article_view = find_or_initialize_by(user_hash: user_hash, article_id: article_id)

    if article_view.new_record?
      article_view.count = 1
      article_view.last_viewed_at = Time.current
    else
      article_view.count += 1
      article_view.last_viewed_at = Time.current
    end

    article_view.save!
    article_view
  end

  def self.top_articles_for_user(user_hash, limit = 5)
    by_user(user_hash)
      .with_articles
      .most_viewed
      .limit(limit)
  end
end
