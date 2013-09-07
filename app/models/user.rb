class User < ActiveRecord::Base
  has_many :pickem_picks
  has_many :fooicide_picks
  has_many :thirty_eights
  has_many :shares
  
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

  def is_team_available?(year, week, team_id)
    pick = fooicide_picks.find_by_year_and_team_id(year, team_id)
    if pick.nil? || pick.week.to_i == week.to_i
      if pick_locked?(year, week)
        return false
      else
        return true
      end
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

  def self.order_all_by_pickem_record(year)
    sorted_users = []
    User.all.map do |user|
      # skip users with no picks
      if user.pickem_picks_by_year(year).try(:count) <= 0
        next
      end
      # Add first user by default
      if sorted_users.empty?
        sorted_users << user
      else
        # Sort all the users by wins
        for i in 0..sorted_users.count - 1
          inserted = false
          if user.pickem_picks_wins_by_year(year) > sorted_users.at(i).pickem_picks_wins_by_year(year)
            inserted = true
            sorted_users.insert(i, user)
          end
          # append to the end if it is the smallest win total
          if !inserted
            sorted_users << user
          end
        end
      end
    end
    return sorted_users
  end

  def self.order_all_by_fooicide_record(year)
    sorted_users = []
    User.all.map do |user|
      # skip users with no picks
      if user.fooicide_picks_by_year(year).try(:count) <= 0
        next
      end
      # Add first user by default
      if sorted_users.empty?
        sorted_users << user
      else
        # Sort all the users by wins
        for i in 0..sorted_users.count - 1
          inserted = false
          if user.fooicide_picks_correct_by_year(year) > sorted_users.at(i).fooicide_picks_correct_by_year(year)
            inserted = true
            sorted_users.insert(i, user)
          end
          # append to the end if it is the smallest win total
          if !inserted
            sorted_users << user
          end
        end
      end
    end
    return sorted_users
  end
end
