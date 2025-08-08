require 'rails_helper'

RSpec.describe 'Search' do
  let(:user_hash) { 'user123' }

  before do
    # Mock the user hash generation to be consistent across all tests
    allow_any_instance_of(ApplicationController).to receive(:generate_user_hash).and_return(user_hash)
  end

  describe 'GET /' do
    it 'returns http success' do
      get root_path
      expect(response).to have_http_status(:success)
    end

    it 'displays the search interface' do
      get root_path
      expect(response.body).to include('Real-time Search')
      expect(response.body).to include('Search Analytics')
    end

    context 'with query parameter' do
      let!(:article) { create(:article, title: 'Ruby on Rails Guide') }

      it 'displays search results' do
        get root_path, params: { q: 'Ruby' }
        expect(response.body).to include('Ruby on Rails Guide')
      end

      it 'shows search results count' do
        get root_path, params: { q: 'Ruby' }
        expect(response.body).to include('Found 1 article')
      end

      it 'displays no results message for no matches' do
        get root_path, params: { q: 'nonexistent' }
        expect(response.body).to include('No results found')
      end
    end
  end

  describe 'GET /search' do
    let!(:article) { create(:article, title: 'Ruby on Rails Guide') }

    it 'returns http success' do
      get search_path
      expect(response).to have_http_status(:success)
    end

    it 'displays search results for query' do
      get search_path, params: { q: 'Ruby' }
      expect(response.body).to include('Ruby on Rails Guide')
    end

    context 'with AJAX request' do
      it 'returns only search results partial' do
        get search_path, params: { q: 'Ruby' }, headers: { 'X-Requested-With' => 'XMLHttpRequest' }
        expect(response.body).to include('Ruby on Rails Guide')
        expect(response.body).not_to include('Search Analytics') # No layout
      end
    end
  end

  describe 'GET /analytics' do
    let!(:search_summary) { create(:search_summary, user_hash: user_hash, term: 'ruby', count: 3) }
    let!(:article) { create(:article, title: 'Ruby Guide') }
    let!(:article_view) { create(:article_view, user_hash: user_hash, article: article, count: 2) }

    it 'returns http success' do
      get analytics_path
      expect(response).to have_http_status(:success)
    end

    it 'displays analytics dashboard' do
      get analytics_path
      expect(response.body).to include('Search Analytics Dashboard')
      expect(response.body).to include('Top Searched Terms')
      expect(response.body).to include('Most Visited Articles')
    end

    it 'displays top searched terms' do
      get analytics_path
      expect(response.body).to include('ruby')
      expect(response.body).to include('Searched 3 time')
    end

    it 'displays most visited articles' do
      get analytics_path
      expect(response.body).to include('Ruby Guide')
      expect(response.body).to include('Viewed 2 time')
    end

    it 'displays search statistics' do
      get analytics_path
      expect(response.body).to include('Total Searches')
      expect(response.body).to include('Article Views')
    end

    it 'makes search terms clickable' do
      get analytics_path
      expect(response.body).to include('href="/search?q=ruby"')
    end

    it 'makes article titles clickable' do
      get analytics_path
      expect(response.body).to include("href=\"/articles/#{article.id}\"")
    end

    context 'with no data' do
      before do
        SearchSummary.destroy_all
        ArticleView.destroy_all
      end

      it 'displays no data messages' do
        get analytics_path
        expect(response.body).to include('No search data available yet')
        expect(response.body).to include('No article views yet')
      end
    end
  end

  describe 'Search from analytics' do
    let!(:search_summary) { create(:search_summary, user_hash: user_hash, term: 'ruby', count: 3) }
    let!(:article) { create(:article, title: 'Ruby on Rails Guide') }

    it 'redirects to search with query parameter' do
      get search_path, params: { q: 'ruby' }
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Ruby on Rails Guide')
    end

    it 'displays search results for clicked term' do
      get search_path, params: { q: 'ruby' }
      expect(response.body).to include('Search Results for "ruby"')
    end
  end

  describe 'Navigation' do
    it 'provides navigation between pages' do
      get root_path
      expect(response.body).to include('href="/"')
      expect(response.body).to include('href="/analytics"')

      get analytics_path
      expect(response.body).to include('href="/"')
      expect(response.body).to include('href="/analytics"')
    end
  end
end
