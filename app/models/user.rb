class User < ActiveRecord::Base
  has_many :pickem_picks
  has_many :fooicide_picks
  has_many :thirty_eights  
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  
  # methods
  def pickem_pick_by_game(game)
    pickem_picks.find_by_game_id(game.id)
  end
  
  def pickem_picks_by_year_and_week(year, week)
    pickem_picks.find_all_by_year_and_week(year, week)
  end
  
  def pickem_picks_record_by_year(year)
    wins = 0
    losses = 0
    pickem_picks.find_all_by_year(year).try(:map) do |pick|
      if !pick.win.nil?
        pick.win == true ? wins += 1 : losses += 1       
      end
    end
    return "(#{wins}-#{losses})"
  end
  
  def pickem_picks_record_by_year_and_week(year, week)
    wins = 0
    losses = 0
    pickem_picks.find_all_by_year_and_week(year, week).try(:map) do |pick|
      if !pick.win.nil?
        pick.win == true ? wins += 1 : losses += 1       
      end
    end
    return "(#{wins}-#{losses})"
  end
end
