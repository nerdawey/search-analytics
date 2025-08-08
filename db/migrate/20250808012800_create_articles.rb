class CreateArticles < ActiveRecord::Migration[7.1]
  def change
    create_table :articles do |t|
      t.string :title, null: false
      t.text :content, null: false
      t.datetime :published_at

      t.timestamps
    end
    
    add_index :articles, :title
    add_index :articles, :published_at
  end
end
