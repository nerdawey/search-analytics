class ArticleViewService < BaseService
  def initialize(user_hash)
    @user_hash = user_hash
  end

  def call(article)
    result = ArticleView.increment_or_create(
      user_hash: @user_hash,
      article_id: article.id
    )
    success(result)
  end

  def track_view(article)
    call(article)[:result]
  end
end
