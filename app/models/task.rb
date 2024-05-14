class Task < ApplicationRecord
  validates :title, presence: true
  validates :description, presence: true
  validates :status, inclusion: { in: [0, 1, 2], message: "%{value} is not a valid status" }
end
