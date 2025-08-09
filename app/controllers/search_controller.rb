class SearchController < ApplicationController
  before_action :set_user_hash

  def index
    @query = params[:q]
    @articles = SearchService.new(@query).perform_search

    render partial: 'search_results', locals: { articles: @articles, query: @query } if request.xhr?
  end

  def analytics
    analytics_data = SearchAnalyticsService.new(@user_hash).analytics_data

    @top_searches = analytics_data[:top_searches]
    @recent_searches = analytics_data[:recent_searches]
    @top_articles = analytics_data[:top_articles]
    @total_searches = analytics_data[:total_searches]
    @unique_terms = analytics_data[:unique_terms]
    @total_article_views = analytics_data[:total_article_views]
    @recent_activity = analytics_data[:recent_activity]
  end

  private

  def set_user_hash
    @user_hash = generate_user_hash
  end
end
