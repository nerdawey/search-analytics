require 'rails_helper'

RSpec.describe ArticleView do
  describe 'associations' do
    it { is_expected.to belong_to(:article) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user_hash) }
    it { is_expected.to validate_presence_of(:count) }
    it { is_expected.to validate_presence_of(:last_viewed_at) }
    it { is_expected.to validate_numericality_of(:count).is_greater_than(0) }

    it 'validates uniqueness of article_id scoped to user_hash' do
      user_hash = 'user123'
      article = create(:article)

      create(:article_view, user_hash: user_hash, article: article)

      duplicate_view = build(:article_view, user_hash: user_hash, article: article)
      expect(duplicate_view).not_to be_valid
      expect(duplicate_view.errors[:article_id]).to include('has already been taken')
    end
  end

  describe 'scopes' do
    let(:user_hash) { 'user123' }
    let(:article1) { create(:article) }
    let(:article2) { create(:article) }
    let!(:article_view1) { create(:article_view, user_hash: user_hash, article: article1, count: 3) }
    let!(:article_view2) { create(:article_view, user_hash: user_hash, article: article2, count: 1) }
    let!(:other_user_view) { create(:article_view, user_hash: 'other_user', article: article1, count: 2) }

    describe '.by_user' do
      it 'returns article views for the specified user' do
        expect(described_class.by_user(user_hash)).to include(article_view1, article_view2)
        expect(described_class.by_user(user_hash)).not_to include(other_user_view)
      end
    end

    describe '.recent' do
      it 'orders by last_viewed_at descending' do
        expect(described_class.recent.to_a).to eq([other_user_view, article_view2, article_view1])
      end
    end

    describe '.most_viewed' do
      it 'orders by count descending' do
        expect(described_class.most_viewed.to_a).to eq([article_view1, other_user_view, article_view2])
      end
    end
  end

  describe '.increment_or_create' do
    let(:user_hash) { 'user123' }
    let(:article) { create(:article) }

    context 'when article view does not exist' do
      it 'creates a new article view with count 1' do
        expect do
          described_class.increment_or_create(user_hash: user_hash, article_id: article.id)
        end.to change(described_class, :count).by(1)

        article_view = described_class.last
        expect(article_view.user_hash).to eq(user_hash)
        expect(article_view.article_id).to eq(article.id)
        expect(article_view.count).to eq(1)
        expect(article_view.last_viewed_at).to be_within(1.second).of(Time.current)
      end
    end

    context 'when article view already exists' do
      let!(:existing_view) do
        create(:article_view,
               user_hash: user_hash,
               article: article,
               count: 2,
               last_viewed_at: 1.hour.ago)
      end

      it 'increments the count and updates last_viewed_at' do
        expect do
          described_class.increment_or_create(user_hash: user_hash, article_id: article.id)
        end.not_to change(described_class, :count)

        existing_view.reload
        expect(existing_view.count).to eq(3)
        expect(existing_view.last_viewed_at).to be_within(1.second).of(Time.current)
      end
    end

    context 'with invalid parameters' do
      it 'raises an error for invalid article_id' do
        expect do
          described_class.increment_or_create(user_hash: user_hash, article_id: 99_999)
        end.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe '.top_articles_for_user' do
    let(:user_hash) { 'user123' }
    let(:article1) { create(:article, title: 'Article 1') }
    let(:article2) { create(:article, title: 'Article 2') }
    let(:article3) { create(:article, title: 'Article 3') }

    before do
      create(:article_view, user_hash: user_hash, article: article1, count: 3)
      create(:article_view, user_hash: user_hash, article: article2, count: 1)
      create(:article_view, user_hash: user_hash, article: article3, count: 5)
    end

    it 'returns articles ordered by view count descending' do
      top_articles = described_class.top_articles_for_user(user_hash, 3)
      expect(top_articles.map(&:article)).to eq([article3, article1, article2])
    end

    it 'respects the limit parameter' do
      top_articles = described_class.top_articles_for_user(user_hash, 2)
      expect(top_articles.count).to eq(2)
      expect(top_articles.first.article).to eq(article3)
      expect(top_articles.second.article).to eq(article1)
    end

    it 'includes the article association' do
      top_articles = described_class.top_articles_for_user(user_hash, 1)
      expect(top_articles.first.article).to be_present
      expect(top_articles.first.article.title).to eq('Article 3')
    end

    it 'only returns articles for the specified user' do
      other_user_view = create(:article_view, user_hash: 'other_user', article: article1, count: 10)

      top_articles = described_class.top_articles_for_user(user_hash, 5)
      expect(top_articles).not_to include(other_user_view)
    end
  end
end
