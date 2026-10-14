class Conversation < ApplicationRecord
  belongs_to :chatbot
  has_many :messages, dependent: :destroy

  validates :visitor_id, presence: true
end
