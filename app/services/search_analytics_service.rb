class SearchAnalyticsService < BaseService
  def initialize(user_hash)
    @user_hash = user_hash
  end

  def call
    user_summaries = SearchSummary.by_user(@user_hash)
    user_article_views = ArticleView.by_user(@user_hash)

    analytics_data = {
      top_searches: SearchSummary.top_searches_for_user(@user_hash, 10),
      recent_searches: SearchSummary.recent_searches_for_user(@user_hash, 10),
      top_articles: ArticleView.top_articles_for_user(@user_hash, 5),
      total_searches: user_summaries.sum(:count),
      unique_terms: user_summaries.count,
      total_article_views: user_article_views.sum(:count),
      recent_activity: recent_activity
    }

    success(analytics_data)
  end

  def analytics_data
    call[:result]
  end

  private

  def recent_activity
    SearchSummary.by_user(@user_hash)
      .where(last_searched_at: 7.days.ago..)
      .order(:last_searched_at)
  end
end
