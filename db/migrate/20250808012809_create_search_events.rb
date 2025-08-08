class CreateSearchEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :search_events do |t|
      t.string :user_hash, null: false
      t.string :session_id, null: false
      t.text :raw_value, null: false
      t.string :event_type, null: false

      t.timestamps
    end
    
    add_index :search_events, :user_hash
    add_index :search_events, :session_id
    add_index :search_events, :event_type
    add_index :search_events, :created_at
    add_index :search_events, [:user_hash, :session_id]
  end
end
