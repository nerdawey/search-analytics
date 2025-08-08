require 'rails_helper'

RSpec.describe SearchController do
  let(:user_hash) { 'user123' }

  describe 'GET #index' do
    before do
      allow(controller).to receive(:generate_user_hash).and_return(user_hash)
    end

    context 'without query parameter' do
      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'assigns empty articles array' do
        get :index
        expect(assigns(:articles)).to eq([])
      end

      it 'assigns nil query' do
        get :index
        expect(assigns(:query)).to be_nil
      end
    end

    context 'with query parameter' do
      let!(:article) { create(:article, title: 'Ruby on Rails Guide') }

      it 'returns http success' do
        get :index, params: { q: 'Ruby' }
        expect(response).to have_http_status(:success)
      end

      it 'assigns matching articles' do
        get :index, params: { q: 'Ruby' }
        expect(assigns(:articles)).to include(article)
      end

      it 'assigns the query parameter' do
        get :index, params: { q: 'Ruby' }
        expect(assigns(:query)).to eq('Ruby')
      end

      it 'finds articles by title' do
        get :index, params: { q: 'Rails' }
        expect(assigns(:articles)).to include(article)
      end

      it 'returns empty results for no matches' do
        get :index, params: { q: 'nonexistent' }
        expect(assigns(:articles)).to be_empty
      end
    end

    context 'with AJAX request' do
      let!(:article) { create(:article, title: 'Ruby on Rails Guide') }

      it 'renders search results partial' do
        get :index, params: { q: 'Ruby' }, xhr: true
        expect(response).to render_template(partial: '_search_results')
      end

      it 'passes correct locals to partial' do
        get :index, params: { q: 'Ruby' }, xhr: true
        expect(assigns(:articles)).to include(article)
        expect(assigns(:query)).to eq('Ruby')
      end
    end
  end

  describe 'GET #analytics' do
    before do
      allow(controller).to receive(:generate_user_hash).and_return(user_hash)
    end

    let!(:search_summary1) { create(:search_summary, user_hash: user_hash, term: 'ruby', count: 5) }
    let!(:search_summary2) { create(:search_summary, user_hash: user_hash, term: 'rails', count: 3) }
    let!(:other_user_summary) { create(:search_summary, user_hash: 'other_user', term: 'javascript', count: 10) }
    let!(:article) { create(:article, title: 'Ruby Guide') }
    let!(:article_view) { create(:article_view, user_hash: user_hash, article: article, count: 2) }

    it 'returns http success' do
      get :analytics
      expect(response).to have_http_status(:success)
    end

    it 'assigns top searches for the user' do
      get :analytics
      expect(assigns(:top_searches)).to include(search_summary1, search_summary2)
      expect(assigns(:top_searches)).not_to include(other_user_summary)
    end

    it 'assigns recent searches for the user' do
      get :analytics
      expect(assigns(:recent_searches)).to include(search_summary1, search_summary2)
    end

    it 'assigns top articles for the user' do
      get :analytics
      expect(assigns(:top_articles)).to include(article_view)
    end

    it 'calculates total searches correctly' do
      get :analytics
      expect(assigns(:total_searches)).to eq(8) # 5 + 3
    end

    it 'calculates unique terms correctly' do
      get :analytics
      expect(assigns(:unique_terms)).to eq(2) # ruby, rails
    end

    it 'calculates total article views correctly' do
      get :analytics
      expect(assigns(:total_article_views)).to eq(2)
    end

    it 'assigns recent activity from last 7 days' do
      recent_summary = create(:search_summary, user_hash: user_hash, term: 'recent', last_searched_at: 1.day.ago)
      old_summary = create(:search_summary, user_hash: user_hash, term: 'old', last_searched_at: 10.days.ago)

      get :analytics
      expect(assigns(:recent_activity)).to include(recent_summary)
      expect(assigns(:recent_activity)).not_to include(old_summary)
    end

    it 'orders top searches by count descending' do
      get :analytics
      expect(assigns(:top_searches).first).to eq(search_summary1) # count: 5
      expect(assigns(:top_searches).second).to eq(search_summary2) # count: 3
    end

    it 'orders recent searches by last_searched_at descending' do
      get :analytics
      expect(assigns(:recent_searches).first).to eq(search_summary2) # more recent
      expect(assigns(:recent_searches).second).to eq(search_summary1)
    end
  end

  describe 'user identification' do
    it 'generates user hash based on IP and session' do
      allow(request).to receive(:remote_ip).and_return('192.168.1.1')
      allow(session).to receive(:id).and_return('session123')
      allow(Rails.application).to receive(:secret_key_base).and_return('secret')

      get :index
      actual_hash = assigns(:user_hash)

      # Use the actual values that were used to calculate the expected hash
      actual_ip = request.remote_ip
      actual_session_id = session.id
      actual_secret = Rails.application.secret_key_base
      expected_hash = Digest::SHA256.hexdigest("#{actual_ip}#{actual_session_id}#{actual_secret}")

      expect(actual_hash).to eq(expected_hash)
    end
  end
end
