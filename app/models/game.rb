class Game < ActiveRecord::Base
  has_many :pickem_picks
  has_many :fooicide_picks
  belongs_to :away_team, :class_name => "Team"
  belongs_to :home_team, :class_name => "Team"
  
  attr_accessible :away_score, :date, :home_score, :location, :week, :year, :away_team_id, :home_team_id
  accepts_nested_attributes_for :pickem_picks, :away_team, :home_team
  
  # methods
  
end
