class Account < ActiveRecord::Base
  belongs_to :user
  has_many :wagers

  attr_accessor :amount, :user_id, :year
end
