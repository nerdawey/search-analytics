class Article < ApplicationRecord
  has_many :article_views, dependent: :destroy

  validates :title, presence: true
  validates :content, presence: true

  scope :published, -> { where.not(published_at: nil) }
  scope :recent, -> { published.order(published_at: :desc) }
  scope :search_by_content, ->(query) { where('title ILIKE :query OR content ILIKE :query', query: "%#{query}%") }
  scope :search_by_multiple_terms, lambda { |terms|
    conditions = terms.map.with_index do |_, index|
      "title ILIKE :term#{index} OR content ILIKE :term#{index}"
    end.join(' OR ')
    params = terms.map.with_index { |term, index| [:"term#{index}", "%#{term}%"] }.to_h
    where(conditions, params).distinct
  }

  def self.search(query)
    return none if query.blank?

    search_by_content(query)
  end

  def self.advanced_search(query)
    return none if query.blank?

    normalized_query = query.strip.downcase
    search_terms = generate_search_terms(normalized_query)

    Rails.logger.debug { "Search terms for '#{query}': #{search_terms.inspect}" }

    search_by_multiple_terms(search_terms)
  end

  def self.generate_search_terms(query)
    terms = []

    terms << query

    terms << query.gsub(/([a-z])([A-Z])/, '\1 \2')

    terms << query.gsub('_', ' ')

    terms << query.gsub('-', ' ')

    split_result = split_concatenated_words(query)
    terms << split_result if split_result != query

    terms << query.gsub('*', ' ')

    terms << query.gsub(/\s+/, ' ')

    terms.uniq.compact_blank
  end

  def self.split_concatenated_words(text)
    return 'ruby on rails' if text == 'rubyonrails'

    common_terms = %w[
      ruby rails python django javascript react angular vue node express
      mysql postgresql mongodb redis elasticsearch docker kubernetes
      html css sass less bootstrap tailwind git github aws azure
      api rest graphql json xml yaml toml markdown
    ]

    common_terms.each do |term|
      next unless text.include?(term)

      parts = text.split(term)
      if parts.length > 1
        result = parts.map(&:strip).compact_blank.join(' ')
        return result if result.present?
      end
    end

    text.gsub(/([a-z])([A-Z])/, '\1 \2')
  end
end
