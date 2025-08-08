require 'rails_helper'

RSpec.describe SearchSummary do
  describe 'validations' do
    subject { build(:search_summary) }

    it { is_expected.to validate_presence_of(:user_hash) }
    it { is_expected.to validate_presence_of(:term) }
    it { is_expected.to validate_presence_of(:count) }
    it { is_expected.to validate_presence_of(:last_searched_at) }
    it { is_expected.to validate_numericality_of(:count).is_greater_than(0) }
    it { is_expected.to validate_uniqueness_of(:user_hash).scoped_to(:term) }
  end

  describe 'scopes' do
    let!(:summary1) do
      create(:search_summary, user_hash: 'user1', term: 'rails', count: 5, last_searched_at: 1.day.ago)
    end
    let!(:summary2) do
      create(:search_summary, user_hash: 'user1', term: 'javascript', count: 3, last_searched_at: 2.days.ago)
    end
    let!(:summary3) do
      create(:search_summary, user_hash: 'user2', term: 'python', count: 10, last_searched_at: 3.days.ago)
    end

    describe '.recent' do
      it 'orders summaries by last_searched_at desc' do
        expect(described_class.recent.to_a).to eq([summary1, summary2, summary3])
      end
    end

    describe '.by_user' do
      it 'filters summaries by user_hash' do
        expect(described_class.by_user('user1')).to include(summary1, summary2)
        expect(described_class.by_user('user1')).not_to include(summary3)
      end
    end

    describe '.top_terms' do
      it 'orders by count desc and limits results' do
        expect(described_class.top_terms(2).to_a).to eq([summary3, summary1])
      end
    end
  end

  describe '.normalize_term' do
    it 'normalizes terms correctly' do
      expect(described_class.normalize_term('  Hello World  ')).to eq('hello world')
      expect(described_class.normalize_term('RUBY')).to eq('ruby')
      expect(described_class.normalize_term('')).to be_nil
      expect(described_class.normalize_term(nil)).to be_nil
    end
  end

  describe '.increment_or_create' do
    let(:user_hash) { 'user1' }
    let(:term) { 'rails' }

    context 'when summary does not exist' do
      it 'creates a new summary' do
        expect do
          described_class.increment_or_create(user_hash: user_hash, term: term)
        end.to change(described_class, :count).by(1)

        summary = described_class.last
        expect(summary.user_hash).to eq(user_hash)
        expect(summary.term).to eq('rails')
        expect(summary.count).to eq(1)
      end
    end

    context 'when summary already exists' do
      let!(:existing_summary) { create(:search_summary, user_hash: user_hash, term: 'rails', count: 3) }

      it 'increments the count' do
        expect do
          described_class.increment_or_create(user_hash: user_hash, term: term)
        end.not_to change(described_class, :count)

        existing_summary.reload
        expect(existing_summary.count).to eq(4)
      end

      it 'updates last_searched_at' do
        old_time = existing_summary.last_searched_at
        Timecop.travel(1.hour.from_now) do
          described_class.increment_or_create(user_hash: user_hash, term: term)
          existing_summary.reload
          expect(existing_summary.last_searched_at).to be > old_time
        end
      end
    end

    context 'with blank term' do
      it 'does not create summary' do
        expect do
          described_class.increment_or_create(user_hash: user_hash, term: '')
        end.not_to change(described_class, :count)
      end
    end

    context 'with whitespace term' do
      it 'does not create summary' do
        expect do
          described_class.increment_or_create(user_hash: user_hash, term: '   ')
        end.not_to change(described_class, :count)
      end
    end
  end

  describe '.top_searches_for_user' do
    let(:user_hash) { 'user1' }
    let!(:summary1) { create(:search_summary, user_hash: user_hash, term: 'rails', count: 5) }
    let!(:summary2) { create(:search_summary, user_hash: user_hash, term: 'javascript', count: 10) }
    let!(:summary3) { create(:search_summary, user_hash: user_hash, term: 'python', count: 3) }

    it 'returns top searches for user ordered by count' do
      results = described_class.top_searches_for_user(user_hash, 2)
      expect(results.to_a).to eq([summary2, summary1])
    end

    it 'limits results correctly' do
      results = described_class.top_searches_for_user(user_hash, 1)
      expect(results.count).to eq(1)
      expect(results.first).to eq(summary2)
    end
  end

  describe '.recent_searches_for_user' do
    let(:user_hash) { 'user1' }
    let!(:summary1) { create(:search_summary, user_hash: user_hash, term: 'rails', last_searched_at: 1.day.ago) }
    let!(:summary2) { create(:search_summary, user_hash: user_hash, term: 'javascript', last_searched_at: 2.days.ago) }
    let!(:summary3) { create(:search_summary, user_hash: user_hash, term: 'python', last_searched_at: 3.days.ago) }

    it 'returns recent searches for user ordered by last_searched_at' do
      results = described_class.recent_searches_for_user(user_hash, 2)
      expect(results.to_a).to eq([summary1, summary2])
    end

    it 'limits results correctly' do
      results = described_class.recent_searches_for_user(user_hash, 1)
      expect(results.count).to eq(1)
      expect(results.first).to eq(summary1)
    end
  end
end
