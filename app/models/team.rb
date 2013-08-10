class Team < ActiveRecord::Base
  has_many :records
  has_many :thirty_eights
  has_many :home_games, :foreign_key => "home_team_id", :class_name => "Game", :primary_key => "id"
  has_many :away_games, :foreign_key => "away_team_id", :class_name => "Game", :primary_key => "id"
  
  attr_accessible :conference, :division, :image, :location, :name
  
  # methods
  def record_formatted(year)
    record = records.find_by_year(year)
    return "(#{record.wins}-#{record.losses})" unless record.nil?
  end
end
