class CreateArticleViews < ActiveRecord::Migration[7.1]
  def change
    create_table :article_views do |t|
      t.string :user_hash, null: false
      t.references :article, null: false, foreign_key: true
      t.integer :count, null: false, default: 1
      t.datetime :last_viewed_at, null: false

      t.timestamps
    end
    
    add_index :article_views, :user_hash
    add_index :article_views, [:user_hash, :article_id], unique: true
    add_index :article_views, :last_viewed_at
  end
end
