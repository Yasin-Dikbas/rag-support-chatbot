class CreateConversations < ActiveRecord::Migration[8.1]
  def change
    create_table :conversations do |t|
      t.references :chatbot, null: false, foreign_key: true
      t.string :visitor_id, null: false

      t.timestamps
    end

    add_index :conversations, [ :chatbot_id, :visitor_id ]
  end
end
