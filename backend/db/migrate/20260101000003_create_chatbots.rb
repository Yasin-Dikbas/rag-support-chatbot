class CreateChatbots < ActiveRecord::Migration[8.1]
  def change
    create_table :chatbots do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.string :welcome_message, default: "Merhaba! Size nasıl yardımcı olabilirim?"
      t.string :widget_key, null: false

      t.timestamps
    end

    add_index :chatbots, :widget_key, unique: true
  end
end
