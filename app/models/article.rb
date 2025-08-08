class Article < ApplicationRecord
  has_many :article_views, dependent: :destroy

  validates :title, presence: true
  validates :content, presence: true

  scope :published, -> { where.not(published_at: nil) }
  scope :recent, -> { published.order(published_at: :desc) }

  def self.search(query)
    return none if query.blank?

    where('title ILIKE ? OR content ILIKE ?', "%#{query}%", "%#{query}%")
  end
end
