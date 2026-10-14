class CreateDocuments < ActiveRecord::Migration[8.1]
  def change
    create_table :documents do |t|
      t.references :chatbot, null: false, foreign_key: true
      t.string :title, null: false
      t.string :source_type, default: "file", null: false
      t.string :status, default: "pending", null: false
      t.text :source_text
      t.text :raw_text
      t.text :error_message
      t.integer :char_count
      t.integer :chunk_count, default: 0

      t.timestamps
    end

    add_index :documents, :status
  end
end
