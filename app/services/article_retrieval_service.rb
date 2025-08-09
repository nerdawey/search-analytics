class ArticleRetrievalService < BaseService
  def initialize(article_id)
    @article_id = article_id
  end

  def call
    article = Article.find(@article_id)
    success(article)
  rescue ActiveRecord::RecordNotFound
    failure('Article not found')
  end
end
