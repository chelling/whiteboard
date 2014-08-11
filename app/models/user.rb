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
  attr_accessible :email, :password, :password_confirmation, :remember_me
  
  # methods
  # pickem_picks
  def pickem_pick_by_game(game)
    pickem_picks.find_by_game_id(game.id)
  end

  def pickem_pick_by_game_id(id)
    pickem_picks.find_by_game_id(id)
  end
  
  def pickem_picks_by_year_and_week(year, week)
    pickem_picks.find_all_by_year_and_week(year, week)
  end

  def pickem_picks_by_year(year)
    pickem_picks.find_all_by_year(year)
  end

  def pickem_picks_wins_by_year(year)
    wins = 0
    pickem_picks.find_all_by_year(year).try(:map) do |pick|
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
    pickem_picks.find_all_by_year(year).try(:map) do |pick|
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
    pickem_picks.find_all_by_year_and_week(year, week).try(:map) do |pick|
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
    pickem_picks.find_all_by_year(year).try(:map) do |pick|
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
    fooicide_picks.find_by_game_id(game.id)
  end

  def fooicide_pick_by_game_id(id)
    fooicide_picks.find_by_game_id(id)
  end

  def fooicide_pick_by_year_and_week(year, week)
    fooicide_picks.find_by_year_and_week(year, week)
  end

  def fooicide_picks_by_year(year)
    fooicide_picks.find_all_by_year(year)
  end

  def fooicide_pick_after_game_start(year, week)
    pick = fooicide_picks.find_by_year_and_week(year, week)
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
    fooicide_picks.find_all_by_year(year).try(:map) do |pick|
      if !pick.win.nil?
        pick.win ? correct += 1 : incorrect += 1
      end
    end

    return correct
  end

  def fooicide_picks_incorrect_by_year(year)
    correct = 0
    incorrect = 0
    fooicide_picks.find_all_by_year(year).try(:map) do |pick|
      if !pick.win.nil?
        pick.win ? correct += 1 : incorrect += 1
      end
    end

    return incorrect
  end

  def fooicide_picks_record_by_year(year)
    correct = 0
    incorrect = 0
    fooicide_picks.find_all_by_year(year).try(:map) do |pick|
      if !pick.win.nil?
        pick.win ? correct += 1 : incorrect += 1
      end
    end

    return "(#{correct}-#{incorrect})"
  end

  # other methods

  def find_balance_by_year(year)
    amount = accounts.find_by_year(year).try(:amount)
    amount.nil? ? "$0" : "$#{amount.round(2)}"
  end

  def find_balance_prior_to_week(year, week)
    current_amount = accounts.find_by_year(year).try(:amount)
    amount = 0
    wagers = self.wagers.joins(:pickem_picks).where("pickem_picks.year = ? and pickem_picks.week = ?", year, week)
    wagers.each do |wager|
      amount += wager.amount
    end

    return "$#{current_amount + amount}"
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
    pick = fooicide_picks.find_by_year_and_team_id(year, team_id)
    current_pick = fooicide_picks.find_by_year_and_week(year, week)

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
    if !fooicide_picks.find_by_year_and_week(year, week).nil?
      return true
    else
      return false
    end
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
