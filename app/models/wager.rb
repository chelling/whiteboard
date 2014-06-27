class Wager < ActiveRecord::Base
  belongs_to :account
  has_and_belongs_to_many :pickem_picks

  attr_accessible :account_id, :amount, :payout, :potential_payout, :win
end
