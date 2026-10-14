class Chatbot < ApplicationRecord
  belongs_to :user
  has_many :documents, dependent: :destroy
  has_many :chunks, dependent: :destroy
  has_many :conversations, dependent: :destroy

  validates :name, presence: true

  before_validation :assign_widget_key, on: :create

  def regenerate_widget_key!
    update!(widget_key: SecureRandom.uuid)
  end

  private

  def assign_widget_key
    self.widget_key ||= SecureRandom.uuid
  end
end
