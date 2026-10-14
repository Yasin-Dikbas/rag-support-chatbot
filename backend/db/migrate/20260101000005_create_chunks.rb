class CreateChunks < ActiveRecord::Migration[8.1]
  def change
    create_table :chunks do |t|
      t.references :document, null: false, foreign_key: true
      t.references :chatbot, null: false, foreign_key: true
      t.integer :chunk_index, null: false
      t.text :content, null: false
      t.float :embedding, array: true, default: []

      t.timestamps
    end
  end
end
