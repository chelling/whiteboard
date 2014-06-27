class Account < ActiveRecord::Base
  belongs_to :user
  has_many :wagers

  attr_accessible :amount, :user_id, :year
end
