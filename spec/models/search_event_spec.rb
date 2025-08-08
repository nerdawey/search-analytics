require 'rails_helper'

RSpec.describe SearchEvent do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:user_hash) }
    it { is_expected.to validate_presence_of(:session_id) }
    it { is_expected.to validate_presence_of(:raw_value) }
    it { is_expected.to validate_presence_of(:event_type) }
    it { is_expected.to validate_inclusion_of(:event_type).in_array(%w[keystroke finalize]) }
  end

  describe 'scopes' do
    let!(:user1_event1) { create(:search_event, user_hash: 'user1', session_id: 'session1', event_type: 'keystroke') }
    let!(:user1_event2) { create(:search_event, user_hash: 'user1', session_id: 'session2', event_type: 'finalize') }
    let!(:user2_event1) { create(:search_event, user_hash: 'user2', session_id: 'session3', event_type: 'keystroke') }

    describe '.recent' do
      it 'orders events by created_at desc' do
        expect(described_class.recent.to_a).to eq([user2_event1, user1_event2, user1_event1])
      end
    end

    describe '.by_user' do
      it 'filters events by user_hash' do
        expect(described_class.by_user('user1')).to include(user1_event1, user1_event2)
        expect(described_class.by_user('user1')).not_to include(user2_event1)
      end
    end

    describe '.by_session' do
      it 'filters events by session_id' do
        expect(described_class.by_session('session1')).to include(user1_event1)
        expect(described_class.by_session('session1')).not_to include(user1_event2, user2_event1)
      end
    end

    describe '.keystrokes' do
      it 'filters keystroke events' do
        expect(described_class.keystrokes).to include(user1_event1, user2_event1)
        expect(described_class.keystrokes).not_to include(user1_event2)
      end
    end

    describe '.finalized' do
      it 'filters finalize events' do
        expect(described_class.finalized).to include(user1_event2)
        expect(described_class.finalized).not_to include(user1_event1, user2_event1)
      end
    end
  end

  describe '.create_keystroke' do
    it 'creates a keystroke event' do
      event = described_class.create_keystroke(
        user_hash: 'user1',
        session_id: 'session1',
        raw_value: 'hello'
      )

      expect(event).to be_persisted
      expect(event.user_hash).to eq('user1')
      expect(event.session_id).to eq('session1')
      expect(event.raw_value).to eq('hello')
      expect(event.event_type).to eq('keystroke')
    end
  end

  describe '.create_finalize' do
    it 'creates a finalize event' do
      event = described_class.create_finalize(
        user_hash: 'user1',
        session_id: 'session1',
        raw_value: 'hello world'
      )

      expect(event).to be_persisted
      expect(event.user_hash).to eq('user1')
      expect(event.session_id).to eq('session1')
      expect(event.raw_value).to eq('hello world')
      expect(event.event_type).to eq('finalize')
    end
  end
end
