class AdvancedSearchService < BaseService
  def initialize(query)
    super
    @query = query
  end

  def call
    return success([]) if @query.blank?

    normalized_query = normalize_query(@query)
    search_terms = generate_search_terms(normalized_query)

    results = perform_search(search_terms)
    success(results)
  end

  private

  def normalize_query(query)
    query.strip.downcase
  end

  def generate_search_terms(query)
    terms = []

    terms << query

    terms << query.gsub(/([a-z])([A-Z])/, '\1 \2')

    terms << query.gsub('_', ' ')

    terms << split_concatenated_words(query)

    terms << query.gsub('*', ' ')

    terms << query.gsub(/\s+/, ' ')

    terms.uniq.compact_blank
  end

  def split_concatenated_words(text)
    common_terms = %w[
      ruby rails python django javascript react angular vue node express
      mysql postgresql mongodb redis elasticsearch docker kubernetes
      html css sass less bootstrap tailwind git github aws azure
      api rest graphql json xml yaml toml markdown
    ]

    common_terms.each do |term|
      next unless text.include?(term)

      parts = text.split(term)
      return parts.map(&:strip).compact_blank.join(' ') if parts.length > 1
    end

    text.gsub(/([a-z])([A-Z])/, '\1 \2')
  end

  def perform_search(search_terms)
    return Article.none if search_terms.empty?

    conditions = search_terms.map do |_term|
      'title ILIKE :term OR content ILIKE :term'
    end.join(' OR ')

    params = search_terms.map.with_index { |term, index| [:"term#{index}", "%#{term}%"] }.to_h

    Article.where(conditions, params).distinct
  end
end
