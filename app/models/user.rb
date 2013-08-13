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

  def fooicide_picks_by_year_and_week(year, week)
    fooicide_picks.find_all_by_year_and_week(year, week)
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

  def is_eliminated?(year)
    if fooicide_picks_incorrect_by_year(year) >= 2
      return true
    else
      return false
    end
  end
end
