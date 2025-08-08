class SearchController < ApplicationController
  before_action :set_user_hash

  def index
    @articles = []
    @query = params[:q]

    @articles = Article.search(@query) if @query.present?

    # If it's an AJAX request, render only the search results
    render partial: 'search_results', locals: { articles: @articles, query: @query } if request.xhr?
  end

  def analytics
    @top_searches = SearchSummary.top_searches_for_user(@user_hash, 10)
    @recent_searches = SearchSummary.recent_searches_for_user(@user_hash, 10)
    @top_articles = ArticleView.top_articles_for_user(@user_hash, 5)

    # Get some basic trends
    @total_searches = SearchSummary.by_user(@user_hash).sum(:count)
    @unique_terms = SearchSummary.by_user(@user_hash).count
    @total_article_views = ArticleView.by_user(@user_hash).sum(:count)

    # Get searches from the last 7 days
    @recent_activity = SearchSummary.by_user(@user_hash)
      .where(last_searched_at: 7.days.ago..)
      .order(:last_searched_at)
  end

  private

  def set_user_hash
    @user_hash = generate_user_hash
  end
end
