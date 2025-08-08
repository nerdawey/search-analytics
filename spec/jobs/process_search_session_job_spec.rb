require 'rails_helper'

RSpec.describe ProcessSearchSessionJob do
  let(:user_hash) { 'user1' }
  let(:session_id) { 'session1' }

  describe '#perform' do
    context 'with finalize event' do
      let!(:keystroke1) do
        create(:search_event, user_hash: user_hash, session_id: session_id, raw_value: 'h', event_type: 'keystroke')
      end
      let!(:keystroke2) do
        create(:search_event, user_hash: user_hash, session_id: session_id, raw_value: 'he', event_type: 'keystroke')
      end
      let!(:finalize) do
        create(:search_event, user_hash: user_hash, session_id: session_id, raw_value: 'hello world',
                              event_type: 'finalize')
      end

      it 'creates search summary from finalize event' do
        expect do
          described_class.perform_now(user_hash: user_hash, session_id: session_id)
        end.to change(SearchSummary, :count).by(1)

        summary = SearchSummary.last
        expect(summary.user_hash).to eq(user_hash)
        expect(summary.term).to eq('hello world')
        expect(summary.count).to eq(1)
      end
    end

    context 'with only keystroke events' do
      let!(:keystroke1) do
        create(:search_event, user_hash: user_hash, session_id: session_id, raw_value: 'h', event_type: 'keystroke')
      end
      let!(:keystroke2) do
        create(:search_event, user_hash: user_hash, session_id: session_id, raw_value: 'he', event_type: 'keystroke')
      end
      let!(:keystroke3) do
        create(:search_event, user_hash: user_hash, session_id: session_id, raw_value: 'hello', event_type: 'keystroke')
      end

      it 'creates search summary from last keystroke' do
        expect do
          described_class.perform_now(user_hash: user_hash, session_id: session_id)
        end.to change(SearchSummary, :count).by(1)

        summary = SearchSummary.last
        expect(summary.term).to eq('hello')
      end
    end

    context 'with no events' do
      it 'does not create search summary' do
        expect do
          described_class.perform_now(user_hash: user_hash, session_id: session_id)
        end.not_to change(SearchSummary, :count)
      end
    end

    context 'with single character term' do
      let!(:keystroke) do
        create(:search_event, user_hash: user_hash, session_id: session_id, raw_value: 'a', event_type: 'keystroke')
      end

      it 'does not create search summary for single character' do
        expect do
          described_class.perform_now(user_hash: user_hash, session_id: session_id)
        end.not_to change(SearchSummary, :count)
      end
    end

    context 'with repeated characters' do
      let!(:keystroke) do
        create(:search_event, user_hash: user_hash, session_id: session_id, raw_value: 'aaaa', event_type: 'keystroke')
      end

      it 'does not create search summary for repeated characters' do
        expect do
          described_class.perform_now(user_hash: user_hash, session_id: session_id)
        end.not_to change(SearchSummary, :count)
      end
    end

    context 'with meaningful search' do
      let!(:keystroke1) do
        create(:search_event, user_hash: user_hash, session_id: session_id, raw_value: 'r', event_type: 'keystroke')
      end
      let!(:keystroke2) do
        create(:search_event, user_hash: user_hash, session_id: session_id, raw_value: 'ra', event_type: 'keystroke')
      end
      let!(:keystroke3) do
        create(:search_event, user_hash: user_hash, session_id: session_id, raw_value: 'rai', event_type: 'keystroke')
      end
      let!(:keystroke4) do
        create(:search_event, user_hash: user_hash, session_id: session_id, raw_value: 'rail', event_type: 'keystroke')
      end
      let!(:keystroke5) do
        create(:search_event, user_hash: user_hash, session_id: session_id, raw_value: 'rails', event_type: 'keystroke')
      end

      it 'creates search summary for meaningful search' do
        expect do
          described_class.perform_now(user_hash: user_hash, session_id: session_id)
        end.to change(SearchSummary, :count).by(1)

        summary = SearchSummary.last
        expect(summary.term).to eq('rails')
      end
    end

    context 'with existing search summary' do
      let!(:existing_summary) { create(:search_summary, user_hash: user_hash, term: 'rails', count: 3) }
      let!(:finalize) do
        create(:search_event, user_hash: user_hash, session_id: session_id, raw_value: 'rails', event_type: 'finalize')
      end

      it 'increments existing search summary' do
        expect do
          described_class.perform_now(user_hash: user_hash, session_id: session_id)
        end.not_to change(SearchSummary, :count)

        existing_summary.reload
        expect(existing_summary.count).to eq(4)
      end
    end

    context 'with mixed case terms' do
      let!(:finalize) do
        create(:search_event, user_hash: user_hash, session_id: session_id, raw_value: 'RUBY ON RAILS',
                              event_type: 'finalize')
      end

      it 'normalizes terms to lowercase' do
        expect do
          described_class.perform_now(user_hash: user_hash, session_id: session_id)
        end.to change(SearchSummary, :count).by(1)

        summary = SearchSummary.last
        expect(summary.term).to eq('ruby on rails')
      end
    end
  end

  describe 'private methods' do
    let(:job) { described_class.new }

    describe '#find_final_event' do
      let(:events) { SearchEvent.none }

      context 'with finalize event' do
        let!(:keystroke) do
          create(:search_event, user_hash: user_hash, session_id: session_id, raw_value: 'hello',
                                event_type: 'keystroke')
        end
        let!(:finalize) do
          create(:search_event, user_hash: user_hash, session_id: session_id, raw_value: 'hello world',
                                event_type: 'finalize')
        end
        let(:events) { SearchEvent.by_user(user_hash).by_session(session_id).order(:created_at) }

        it 'returns finalize event' do
          final_event = job.send(:find_final_event, events)
          expect(final_event).to eq(finalize)
        end
      end

      context 'with only keystrokes' do
        let!(:keystroke1) do
          create(:search_event, user_hash: user_hash, session_id: session_id, raw_value: 'h', event_type: 'keystroke')
        end
        let!(:keystroke2) do
          create(:search_event, user_hash: user_hash, session_id: session_id, raw_value: 'hello',
                                event_type: 'keystroke')
        end
        let(:events) { SearchEvent.by_user(user_hash).by_session(session_id).order(:created_at) }

        it 'returns last keystroke' do
          final_event = job.send(:find_final_event, events)
          expect(final_event).to eq(keystroke2)
        end
      end
    end

    describe '#meaningful_search?' do
      context 'with short term' do
        let(:events) { SearchEvent.none }
        let(:final_term) { 'a' }

        it 'returns false for single character' do
          expect(job.send(:meaningful_search?, events, final_term)).to be false
        end
      end

      context 'with repeated characters' do
        let(:events) { SearchEvent.none }
        let(:final_term) { 'aaaa' }

        it 'returns false for repeated characters' do
          expect(job.send(:meaningful_search?, events, final_term)).to be false
        end
      end

      context 'with meaningful term' do
        let(:events) { SearchEvent.none }
        let(:final_term) { 'rails' }

        it 'returns true for meaningful term' do
          expect(job.send(:meaningful_search?, events, final_term)).to be true
        end
      end
    end
  end
end
