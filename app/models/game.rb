class Game < ActiveRecord::Base
  has_many :pickem_picks
  has_many :fooicide_picks
  
  attr_accessible :away_score, :date, :home_score, :location, :week, :year, :away_team_id, :home_team_id
  accepts_nested_attributes_for :pickem_picks
  
  # methods
  
  def away_team
    Team.find_by_id(away_team_id)
  end
  
  def home_team
    Team.find_by_id(home_team_id)
  end
end
