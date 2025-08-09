class ArticlesController < ApplicationController
  before_action :set_user_hash

  def show
    result = ArticleRetrievalService.new(params[:id]).call

    if result[:success?]
      @article = result[:result]
      ArticleViewService.new(@user_hash).track_view(@article)
    else
      redirect_to root_path, alert: 'Article not found.'
    end
  end

  private

  def set_user_hash
    @user_hash = generate_user_hash
  end
end
