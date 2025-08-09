require 'rails_helper'

RSpec.describe ArticlesController do
  let(:article) { create(:article) }
  let(:user_hash) { 'user123' }

  describe 'GET #show' do
    before do
      allow(controller).to receive(:generate_user_hash).and_return(user_hash)
    end

    context 'when article exists' do
      it 'returns http success' do
        get :show, params: { id: article.id }
        expect(response).to have_http_status(:success)
      end

      it 'assigns the requested article' do
        get :show, params: { id: article.id }
        expect(assigns(:article)).to eq(article)
      end

      it 'tracks the article view' do
        expect do
          get :show, params: { id: article.id }
        end.to change(ArticleView, :count).by(1)

        article_view = ArticleView.last
        expect(article_view.user_hash).to eq(user_hash)
        expect(article_view.article_id).to eq(article.id)
        expect(article_view.count).to eq(1)
      end

      it 'increments existing article view count' do
        existing_view = create(:article_view, user_hash: user_hash, article: article, count: 2)

        expect do
          get :show, params: { id: article.id }
        end.not_to change(ArticleView, :count)

        existing_view.reload
        expect(existing_view.count).to eq(3)
      end

      it 'renders the show template' do
        get :show, params: { id: article.id }
        expect(response).to render_template(:show)
      end
    end

    context 'when article does not exist' do
      it 'redirects to root path' do
        get :show, params: { id: 99_999 }
        expect(response).to redirect_to(root_path)
      end

      it 'sets an alert message' do
        get :show, params: { id: 99_999 }
        expect(flash[:alert]).to eq('Article not found.')
      end

      it 'does not track article view' do
        expect do
          get :show, params: { id: 99_999 }
        end.not_to change(ArticleView, :count)
      end
    end

    context 'with different users' do
      let(:other_user_hash) { 'other_user' }

      it 'tracks views separately for different users' do
        allow(controller).to receive(:generate_user_hash).and_return(user_hash)
        get :show, params: { id: article.id }

        allow(controller).to receive(:generate_user_hash).and_return(other_user_hash)
        get :show, params: { id: article.id }

        expect(ArticleView.count).to eq(2)
        expect(ArticleView.where(user_hash: user_hash).count).to eq(1)
        expect(ArticleView.where(user_hash: other_user_hash).count).to eq(1)
      end
    end
  end

  describe 'user identification' do
    it 'generates user hash based on IP and persistent user ID' do
      allow(request).to receive(:remote_ip).and_return('192.168.1.1')
      allow(Rails.application).to receive(:secret_key_base).and_return('secret')
      allow(controller).to receive(:cookies).and_return(double(signed: { user_id: 'test-user-id' }))

      get :show, params: { id: article.id }
      actual_hash = assigns(:user_hash)

      actual_ip = request.remote_ip
      actual_user_id = 'test-user-id'
      actual_secret = Rails.application.secret_key_base
      expected_hash = Digest::SHA256.hexdigest("#{actual_ip}#{actual_user_id}#{actual_secret}")

      expect(actual_hash).to eq(expected_hash)
    end
  end
end
