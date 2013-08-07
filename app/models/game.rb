class Game < ActiveRecord::Base
  attr_accessible :away_score, :date, :home_score, :location, :week, :year, :away_team_id, :home_team_id
  
  # methods
  
  def away_team
    Team.find_by_id(away_team_id)
  end
  
  def home_team
    Team.find_by_id(home_team_id)
  end
end
