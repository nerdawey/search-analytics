class CreateSearchSummaries < ActiveRecord::Migration[7.1]
  def change
    create_table :search_summaries do |t|
      t.string :user_hash, null: false
      t.string :term, null: false
      t.integer :count, null: false, default: 1
      t.datetime :last_searched_at, null: false

      t.timestamps
    end
    
    add_index :search_summaries, :user_hash
    add_index :search_summaries, :term
    add_index :search_summaries, :last_searched_at
    add_index :search_summaries, [:user_hash, :term], unique: true
  end
end
