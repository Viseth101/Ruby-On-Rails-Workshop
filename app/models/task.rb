class Task < ApplicationRecord
  validates :title, presence: true

  scope :completed, -> { where(completed: true) }
  scope :pending, -> { where(completed: false) }
end
