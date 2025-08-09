require 'rails_helper'

RSpec.describe 'Articles' do
  let(:article) { create(:article, title: 'Ruby on Rails Guide', content: 'Learn Ruby programming') }
  let(:user_hash) { 'user123' }

  before do
    allow_any_instance_of(ApplicationController).to receive(:generate_user_hash).and_return(user_hash)
  end

  describe 'GET /articles/:id' do
    context 'when article exists' do
      it 'returns http success' do
        get article_path(article)
        expect(response).to have_http_status(:success)
      end

      it 'displays the article content' do
        get article_path(article)
        expect(response.body).to include('Ruby on Rails Guide')
        expect(response.body).to include('Learn Ruby programming')
      end

      it 'tracks the article view' do
        expect do
          get article_path(article)
        end.to change(ArticleView, :count).by(1)

        article_view = ArticleView.last
        expect(article_view.user_hash).to eq(user_hash)
        expect(article_view.article_id).to eq(article.id)
        expect(article_view.count).to eq(1)
      end

      it 'increments existing article view count' do
        existing_view = create(:article_view, user_hash: user_hash, article: article, count: 2)

        expect do
          get article_path(article)
        end.not_to change(ArticleView, :count)

        existing_view.reload
        expect(existing_view.count).to eq(3)
      end

      it 'displays back to search link' do
        get article_path(article)
        expect(response.body).to include('Back to Search')
      end

      it 'displays publication date' do
        get article_path(article)
        expect(response.body).to include(article.published_at.strftime('%B %d, %Y'))
      end
    end

    context 'when article does not exist' do
      it 'redirects to root path' do
        get article_path(99_999)
        expect(response).to redirect_to(root_path)
      end

      it 'sets an alert message' do
        get article_path(99_999)
        follow_redirect!
        expect(response.body).to include('Article not found')
      end
    end

    context 'with different users' do
      let(:other_user_hash) { 'other_user' }

      it 'tracks views separately for different users' do
        allow_any_instance_of(ApplicationController).to receive(:generate_user_hash).and_return(user_hash)
        get article_path(article)

        allow_any_instance_of(ApplicationController).to receive(:generate_user_hash).and_return(other_user_hash)
        get article_path(article)

        expect(ArticleView.count).to eq(2)
        expect(ArticleView.where(user_hash: user_hash).count).to eq(1)
        expect(ArticleView.where(user_hash: other_user_hash).count).to eq(1)
      end
    end
  end

  describe 'Analytics integration' do
    it 'shows article views in analytics dashboard' do
      get article_path(article)

      get analytics_path
      expect(response.body).to include('Most Visited Articles')
      expect(response.body).to include('Ruby on Rails Guide')
      expect(response.body).to include('Viewed 1 time')
    end

    it 'shows multiple article views correctly' do
      get article_path(article)
      get article_path(article)

      get analytics_path
      expect(response.body).to include('Viewed 2 time')
    end
  end
end
