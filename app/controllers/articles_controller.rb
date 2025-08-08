class ArticlesController < ApplicationController
  before_action :set_article, only: [:show]
  before_action :set_user_hash

  def show
    # Track article view for analytics
    track_article_view(@article)
  end

  private

  def set_article
    @article = Article.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: t('articles.not_found')
  end

  def set_user_hash
    @user_hash = generate_user_hash
  end

  def track_article_view(article)
    # Create or increment article view count
    ArticleView.increment_or_create(
      user_hash: @user_hash,
      article_id: article.id
    )
  end
end
