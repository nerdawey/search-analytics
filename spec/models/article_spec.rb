require 'rails_helper'

RSpec.describe Article do
  describe 'associations' do
    it { is_expected.to have_many(:article_views).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:content) }
  end

  describe 'scopes' do
    let!(:published_article) { create(:article, published_at: 1.day.ago) }
    let!(:unpublished_article) { create(:article, published_at: nil) }
    let!(:recent_article) { create(:article, published_at: 1.hour.ago) }

    describe '.published' do
      it 'returns only published articles' do
        expect(described_class.published).to include(published_article, recent_article)
        expect(described_class.published).not_to include(unpublished_article)
      end
    end

    describe '.recent' do
      it 'returns published articles ordered by published_at descending' do
        expect(described_class.recent.to_a).to eq([recent_article, published_article])
      end
    end
  end

  describe '.search' do
    let!(:ruby_article) { create(:article, title: 'Ruby on Rails Guide', content: 'Learn Ruby programming') }
    let!(:javascript_article) { create(:article, title: 'JavaScript Basics', content: 'Learn JavaScript programming') }
    let!(:database_article) { create(:article, title: 'Database Design', content: 'Learn about databases') }

    it 'finds articles by title' do
      results = described_class.search('Ruby')
      expect(results).to include(ruby_article)
      expect(results).not_to include(javascript_article, database_article)
    end

    it 'finds articles by content' do
      results = described_class.search('programming')
      expect(results).to include(ruby_article, javascript_article)
      expect(results).not_to include(database_article)
    end

    it 'is case insensitive' do
      results = described_class.search('ruby')
      expect(results).to include(ruby_article)
    end

    it 'returns empty when no matches' do
      results = described_class.search('nonexistent')
      expect(results).to be_empty
    end

    it 'handles empty query' do
      results = described_class.search('')
      expect(results).to be_empty
    end

    it 'handles nil query' do
      results = described_class.search(nil)
      expect(results).to be_empty
    end
  end

  describe 'article views' do
    let(:article) { create(:article) }
    let(:user_hash) { 'user123' }

    it 'can track views' do
      expect do
        ArticleView.increment_or_create(user_hash: user_hash, article_id: article.id)
      end.to change(article.article_views, :count).by(1)
    end

    it 'can have multiple views from different users' do
      ArticleView.increment_or_create(user_hash: 'user1', article_id: article.id)
      ArticleView.increment_or_create(user_hash: 'user2', article_id: article.id)

      expect(article.article_views.count).to eq(2)
    end
  end
end
