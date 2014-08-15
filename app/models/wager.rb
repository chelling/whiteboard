class Wager < ActiveRecord::Base
  belongs_to :account
  belongs_to :pickem_pick

  before_save :update_payouts

  validates :amount, :presence => true
  validates :account_id, :presence => true
  validates :pickem_pick_id, :presence => true

  attr_accessible :account_id, :pickem_pick_id, :amount, :payout, :potential_payout, :win, :previous_amount

  # before_save
  def update_payouts
    self.potential_payout = 2 * amount

    # first time
    if self.previous_amount.nil?
      self.account.amount -= self.amount
      self.account.save
    elsif self.previous_amount != self.amount
      self.account.amount -= (self.amount - self.previous_amount)
      self.account.save
    end

    # save previous
    self.previous_amount = self.amount

    # undo previous payout
    if !self.payout.nil?
      self.account.amount -= self.payout
      self.account.save
    end

    # change account amount
    if win == 1
      self.payout = self.potential_payout
      self.account.amount += self.payout
      self.account.save
    elsif win == 0
      self.payout = self.amount
      self.account.amount += self.payout
      self.account.save
    elsif win == -1
      self.payout = 0
    end
  end

  # methods
  def self.find_amount_by_user_id_and_game_id(user_id, game_id)
    user = User.find(user_id)
    pick = user.pickem_picks.find_by_game_id(game_id)
    wager = user.wagers.find_by_pickem_pick_id(pick.try(:id))

    wager.nil? ? '' : wager.amount.to_f.round(2)
  end
end
