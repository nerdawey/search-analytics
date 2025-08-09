require 'rails_helper'

RSpec.describe 'Search Performance', type: :request do
  let(:user_hash) { 'user123' }
  let(:session_id) { 'session_123' }

  before do
    create_list(:article, 100)
    allow_any_instance_of(ApplicationController).to receive(:generate_user_hash).and_return(user_hash)
  end

  describe 'Search Performance' do
    it 'performs search queries within acceptable time' do
      start_time = Time.current
      get '/search', params: { q: 'ruby' }
      end_time = Time.current

      response_time = (end_time - start_time) * 1000
      expect(response_time).to be < 500
      expect(response).to have_http_status(:success)
    end

    it 'performs AJAX search requests efficiently' do
      start_time = Time.current
      get '/search', params: { q: 'javascript' }, headers: { 'X-Requested-With' => 'XMLHttpRequest' }
      end_time = Time.current

      response_time = (end_time - start_time) * 1000
      expect(response_time).to be < 200
      expect(response).to have_http_status(:success)
    end
  end

  describe 'API Performance' do
    it 'processes search events quickly' do
      start_time = Time.current
      post '/api/search_events', params: {
        search_event: {
          raw_value: 'performance test',
          event_type: 'keystroke',
          session_id: session_id
        }
      }, as: :json
      end_time = Time.current

      response_time = (end_time - start_time) * 1000
      expect(response_time).to be < 50
      expect(response).to have_http_status(:created)
    end

    it 'handles multiple keystroke events efficiently' do
      start_time = Time.current
      20.times do |i|
        post '/api/search_events', params: {
          search_event: {
            raw_value: "keystroke #{i}",
            event_type: 'keystroke',
            session_id: session_id
          }
        }, as: :json
      end
      end_time = Time.current

      response_time = (end_time - start_time) * 1000
      expect(response_time).to be < 1000
      expect(SearchEvent.count).to eq(20)
    end

    it 'processes finalize events with analytics quickly' do
      5.times do |i|
        post '/api/search_events', params: {
          search_event: {
            raw_value: "finalize test #{i}",
            event_type: 'keystroke',
            session_id: session_id
          }
        }, as: :json
      end

      start_time = Time.current
      post '/api/search_events', params: {
        search_event: {
          raw_value: 'finalize test complete',
          event_type: 'finalize',
          session_id: session_id
        }
      }, as: :json
      end_time = Time.current

      response_time = (end_time - start_time) * 1000
      expect(response_time).to be < 100
      expect(response).to have_http_status(:created)
    end
  end

  describe 'Analytics Performance' do
    before do
      create_list(:search_summary, 50) { |summary, i| summary.term = "term_#{i}" }
      create_list(:article_view, 30)
    end

    it 'loads analytics dashboard quickly' do
      start_time = Time.current
      get '/analytics'
      end_time = Time.current

      response_time = (end_time - start_time) * 1000
      expect(response_time).to be < 200
      expect(response).to have_http_status(:success)
    end

    it 'handles analytics with large datasets' do
      create_list(:search_summary, 100) { |summary, i| summary.term = "large_term_#{i}" }
      create_list(:article_view, 50)

      start_time = Time.current
      get '/analytics'
      end_time = Time.current

      response_time = (end_time - start_time) * 1000
      expect(response_time).to be < 500
      expect(response).to have_http_status(:success)
    end
  end

  describe 'Article Performance' do
    let(:article) { create(:article) }

    it 'loads article pages quickly' do
      start_time = Time.current
      get "/articles/#{article.id}"
      end_time = Time.current

      response_time = (end_time - start_time) * 1000
      expect(response_time).to be < 100
      expect(response).to have_http_status(:success)
    end

    it 'tracks article views efficiently' do
      expect do
        get "/articles/#{article.id}"
      end.to change(ArticleView, :count).by(1)

      expect(response).to have_http_status(:success)
    end

    it 'handles multiple article views efficiently' do
      start_time = Time.current
      10.times { get "/articles/#{article.id}" }
      end_time = Time.current

      response_time = (end_time - start_time) * 1000
      expect(response_time).to be < 1000
      expect(ArticleView.count).to eq(1)
    end
  end

  describe 'Database Performance' do
    it 'performs search queries with database optimization' do
      start_time = Time.current
      results = Article.search('ruby')
      end_time = Time.current

      response_time = (end_time - start_time) * 1000
      expect(response_time).to be < 50
      expect(results).to be_a(ActiveRecord::Relation)
    end

    it 'handles search summary aggregations efficiently' do
      create_list(:search_summary, 100) { |summary, i| summary.term = "agg_term_#{i}" }

      start_time = Time.current
      results = SearchSummary.top_searches_for_user(user_hash, 10)
      end_time = Time.current

      response_time = (end_time - start_time) * 1000
      expect(response_time).to be < 50
      expect(results).to be_a(ActiveRecord::Relation)
    end

    it 'processes article view aggregations quickly' do
      create_list(:article_view, 100)

      start_time = Time.current
      results = ArticleView.top_articles_for_user(user_hash, 10)
      end_time = Time.current

      response_time = (end_time - start_time) * 1000
      expect(response_time).to be < 50
      expect(results).to be_a(ActiveRecord::Relation)
    end
  end

  describe 'Memory Usage' do
    it 'does not leak memory during search operations' do
      initial_memory = GC.stat[:total_allocated_objects]

      100.times do |i|
        get '/search', params: { q: "memory test #{i}" }
      end

      final_memory = GC.stat[:total_allocated_objects]
      memory_increase = final_memory - initial_memory

      expect(memory_increase).to be < 300_000
    end
  end

  describe 'Scalability Benchmarks' do
    it 'maintains performance with increasing data size' do
      [10, 50, 100, 200].each do |size|
        SearchSummary.delete_all
        ArticleView.delete_all

        create_list(:search_summary, size) { |summary, i| summary.term = "scale_term_#{size}_#{i}" }
        create_list(:article_view, size)

        start_time = Time.current
        get '/analytics'
        end_time = Time.current

        response_time = (end_time - start_time) * 1000
        expect(response_time).to be < (size * 3)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'Load Testing' do
    it 'handles multiple rapid requests' do
      start_time = Time.current

      50.times do |i|
        get '/search', params: { q: "load test #{i}" }
        post '/api/search_events', params: {
          search_event: {
            raw_value: "load event #{i}",
            event_type: 'keystroke',
            session_id: "session_#{i}"
          }
        }, as: :json
      end

      end_time = Time.current
      total_time = (end_time - start_time) * 1000

      expect(total_time).to be < 5000
      expect(SearchEvent.count).to eq(50)
    end
  end
end
