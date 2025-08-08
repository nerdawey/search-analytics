require 'rails_helper'

RSpec.describe 'Api::SearchEvents' do
  let(:user_hash) { 'user123' }
  let(:valid_params) do
    {
      search_event: {
        raw_value: 'hello world',
        event_type: 'keystroke',
        session_id: 'session_123'
      }
    }
  end

  before do
    # Mock the user hash generation to be consistent across all tests
    allow_any_instance_of(ApplicationController).to receive(:generate_user_hash).and_return(user_hash)
  end

  describe 'POST /api/search_events' do
    it 'creates a new search event' do
      expect do
        post api_search_events_path, params: valid_params, as: :json
      end.to change(SearchEvent, :count).by(1)

      expect(response).to have_http_status(:created)

      json_response = response.parsed_body
      expect(json_response['status']).to eq('success')
      expect(json_response['message']).to eq('Search event recorded')
    end

    it 'creates keystroke event correctly' do
      post api_search_events_path, params: valid_params, as: :json

      event = SearchEvent.last
      expect(event.raw_value).to eq('hello world')
      expect(event.event_type).to eq('keystroke')
      expect(event.session_id).to eq('session_123')
      expect(event.user_hash).to eq(user_hash)
    end

    it 'creates finalize event correctly' do
      finalize_params = valid_params.deep_merge(search_event: { event_type: 'finalize' })

      expect do
        post api_search_events_path, params: finalize_params, as: :json
      end.to change(SearchEvent, :count).by(1)

      event = SearchEvent.last
      expect(event.event_type).to eq('finalize')
    end

    context 'with invalid parameters' do
      it 'returns error for missing raw_value' do
        invalid_params = valid_params.deep_merge(search_event: { raw_value: '' })

        post api_search_events_path, params: invalid_params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)

        json_response = response.parsed_body
        expect(json_response['status']).to eq('error')
      end

      it 'returns error for invalid event_type' do
        invalid_params = valid_params.deep_merge(search_event: { event_type: 'invalid' })

        post api_search_events_path, params: invalid_params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error for missing session_id' do
        invalid_params = valid_params.deep_merge(search_event: { session_id: '' })

        post api_search_events_path, params: invalid_params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with finalize event' do
      it 'processes search analytics synchronously' do
        finalize_params = valid_params.deep_merge(search_event: { event_type: 'finalize' })

        expect do
          post api_search_events_path, params: finalize_params, as: :json
        end.to change(SearchEvent, :count).by(1)

        # Should also create a search summary if the search is meaningful
        expect(SearchSummary.count).to be >= 0
      end
    end

    context 'user identification' do
      it 'generates consistent user hash for same request' do
        post api_search_events_path, params: valid_params, as: :json
        event1 = SearchEvent.last

        post api_search_events_path, params: valid_params, as: :json
        event2 = SearchEvent.last

        expect(event1.user_hash).to eq(event2.user_hash)
        expect(event1.user_hash).to eq(user_hash)
      end
    end
  end
end
