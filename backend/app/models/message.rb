class Message < ApplicationRecord
  belongs_to :conversation

  enum :role, { user: "user", assistant: "assistant" }, validate: true

  validates :content, presence: true
end
