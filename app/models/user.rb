class User < ActiveRecord::Base
  has_many :pickem_picks
  has_many :fooicide_picks
  has_many :thirty_eights
  has_many :shares
  has_many :accounts
  has_many :wagers, :through => :accounts
  has_many :win_pool_picks
  has_many :win_pool_leagues, :through => :win_pool_picks
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  #attr_accessor :email, :password, :password_confirmation, :remember_me
  
  # methods
  # pickem_picks
  def pickem_pick_by_game(game)
    pickem_picks.where(game: game).first
  end

  def pickem_pick_by_game_id(id)
    pickem_picks.where(game_id: id).first
  end
  
  def pickem_picks_by_year_and_week(year, week)
    pickem_picks.where(year: year, week: week)
  end

  def pickem_picks_by_year(year)
    pickem_picks.where(year: year)
  end

  def pickem_picks_wins_by_year(year)
    wins = 0
    pickem_picks.where(year: year).try(:map) do |pick|
      if !pick.win.nil?
        pick.win == true ? wins += 1 : ""
      end
    end
    return wins
  end
  
  def pickem_picks_record_by_year(year)
    wins = 0
    losses = 0
    ties = 0
    pickem_picks.where(year: year).try(:map) do |pick|
      if !pick.win.nil?
        pick.win == true ? wins += 1 : losses += 1
        if pick.tie
          losses -= 1
          ties += 1
        end
      end
    end
    return "(#{wins}-#{losses}-#{ties})"
  end
  
  def pickem_picks_record_by_year_and_week(year, week)
    wins = 0
    losses = 0
    ties = 0
    pickem_picks.where(year: year, week: week).try(:map) do |pick|
      if !pick.win.nil?
        pick.win == true ? wins += 1 : losses += 1
        if pick.tie
          losses -= 1
          ties += 1
        end
      end
    end
    return "(#{wins}-#{losses}-#{ties})"
  end

  def pickem_picks_recommended_record_by_year(year)
    wins = 0
    losses = 0
    ties = 0
    pickem_picks.where(year: year).try(:map) do |pick|
      if pick.try(:recommended)
        if !pick.win.nil?
          pick.win == true ? wins += 1 : losses += 1
          if pick.tie
            losses -= 1
            ties += 1
          end
        end
      end
    end
    return "(#{wins}-#{losses}-#{ties})"
  end

  # fooicide_picks
  def fooicide_pick_by_game(game)
    fooicide_picks.where(game: game).first
  end

  def fooicide_pick_by_game_id(id)
    fooicide_picks.where(game_id: id).first
  end

  def fooicide_pick_by_year_and_week(year, week)
    fooicide_picks.where(year: year, week: week).first
  end

  def fooicide_picks_by_year(year)
    fooicide_picks.where(year: year)
  end

  def fooicide_pick_after_game_start(year, week)
    pick = fooicide_picks.where(year: year, week: week).first
    if !pick.nil? && pick.try(:game).try(:in_progress_or_complete?)
      return pick
    else
      return nil
    end
  end

  def pick_locked?(year, week)
    if fooicide_pick_after_game_start(year, week)
      return true
    else
      return false
    end
  end

  def fooicide_picks_correct_by_year(year)
    correct = 0
    incorrect = 0
    fooicide_picks.where(year: year).try(:map) do |pick|
      if !pick.win.nil?
        pick.win ? correct += 1 : incorrect += 1
      end
    end

    return correct
  end

  def fooicide_picks_incorrect_by_year(year)
    correct = 0
    incorrect = 0
    fooicide_picks.where(year: year).try(:map) do |pick|
      if !pick.win.nil?
        pick.win ? correct += 1 : incorrect += 1
      end
    end

    return incorrect
  end

  def fooicide_picks_record_by_year(year)
    correct = 0
    incorrect = 0
    fooicide_picks.where(year: year).try(:map) do |pick|
      if !pick.win.nil?
        pick.win ? correct += 1 : incorrect += 1
      end
    end

    return "(#{correct}-#{incorrect})"
  end

  # other methods

  def find_balance_by_year(year)
    amount = accounts.where(year: year).first.try(:amount)
    amount.nil? ? "$0" : "$#{amount.round(2)}"
  end

  def find_balance_prior_to_week(year, week)
    current_amount = accounts.where(year: year).first.try(:amount)
    amount = 0
    wagers = self.wagers.joins(:pickem_pick).where("pickem_picks.year = ? and pickem_picks.week = ?", year, week)
    wagers.each do |wager|
      amount += wager.amount
    end

    return current_amount + amount
  end

  def find_submitted_balance_by_year_and_week(year, week)
    amount = 0
    wagers = self.wagers.joins(:pickem_pick).where("pickem_picks.year = ? and pickem_picks.week = ?", year, week)
    wagers.each do |wager|
      amount += wager.amount
    end
    return "$#{amount}"
  end

  def find_wager_picks_by_year(year)
    wagers = self.wagers.includes(:pickem_pick => :game).where("pickem_picks.year = ?", year)
  end

  def find_wager_picks_by_year_and_week(year, week)
    wagers = self.wagers.includes(:pickem_pick => :game).where("pickem_picks.year = ? and pickem_picks.week = ?", year, week)
  end

  def name_or_email
    return name unless name.nil?
    return email
  end

  def is_team_available?(year, week, team_id)
    pick = fooicide_picks.where(year: year, team_id: team_id).first
    current_pick = fooicide_picks.where(year: year, week: week).first

    if (pick.nil? || pick.week.to_i == week.to_i) && (current_pick.nil? || !current_pick.pick_locked?)
      return true
    else
      return false
    end
  end

  def is_eliminated?(year)
    if fooicide_picks_incorrect_by_year(year) >= 2
      return true
    else
      return false
    end
  end

  def pickem_picks_submitted?(year, week)
    if pickem_picks_by_year_and_week(year, week).try(:count) > 0
      return true
    else
      return false
    end
  end

  def fooicide_picks_submitted?(year, week)
    if !fooicide_picks.where(year: year, week: week).first.nil?
      return true
    else
      return false
    end
  end

  def self.order_all_by_account_amount(year, week)
    users_sorted = []
    users_hash = Hash.new
    amounts_hash = Hash.new

    if year.to_i < 2014
      return User.order_all_by_pickem_record(year)
    end

    User.includes(:accounts).where("accounts.year = ?", year).order("accounts.amount DESC").map do |user|
      a = user.find_balance_prior_to_week(year, week)
      if(a > 0)
        amounts_hash[user.id] = user.find_balance_prior_to_week(year, week)
        users_hash[user.id] = user
      end
    end
    # Start sorting
    while !amounts_hash.empty? do
      max = amounts_hash.max_by{|k,v| v}
      users_sorted << users_hash[max.first]
      amounts_hash.delete(max.first)
    end
    # Return sorted users
    return users_sorted
  end

  def self.order_all_by_pickem_record(year)
    users_sorted = []
    users_hash = Hash.new
    wins_hash = Hash.new
    # Add all the user wins to the Hash
    User.all.map do |user|
      wins_hash[user.id] = user.pickem_picks_wins_by_year(year) unless user.pickem_picks_by_year(year).try(:count) <= 0
      users_hash[user.id] = user
    end
    # Start sorting
    while !wins_hash.empty? do
      max = wins_hash.max_by{|k,v| v}
      users_sorted << users_hash[max.first]
      wins_hash.delete(max.first)
    end
    # Return sorted users
    return users_sorted
  end

  def self.order_all_by_fooicide_record(year)
    users_sorted = []
    users_hash = Hash.new
    wins_hash = Hash.new
    # Add all the user wins to the Hash
    User.all.map do |user|
      wins_hash[user.id] = user.fooicide_picks_correct_by_year(year) unless user.fooicide_picks_by_year(year).try(:count) <= 0
      users_hash[user.id] = user
    end
    # Start sorting
    while !wins_hash.empty? do
      max = wins_hash.max_by{|k,v| v}
      users_sorted << users_hash[max.first]
      wins_hash.delete(max.first)
    end
    # Return sorted users
    return users_sorted
  end
end
