class SearchService < BaseService
  def initialize(query)
    @query = query
  end

  def call
    return success([]) if @query.blank?

    result = Article.advanced_search(@query)
    success(result)
  end

  def perform_search
    call[:result]
  end
end
