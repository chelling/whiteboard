class Team < ActiveRecord::Base
  has_many :records
  has_many :thirty_eights
  has_many :home_games, :foreign_key => "home_team_id", :class_name => "Game", :primary_key => "id"
  has_many :away_games, :foreign_key => "away_team_id", :class_name => "Game", :primary_key => "id"
  has_one :stadium
  
  attr_accessible :conference, :division, :image, :location, :name
  
  # methods
  def update_records_by_year(year)
    wins = 0
    losses = 0
    home_games.find_all_by_year(year).try(:map) do |game|
      if !game.home_score.nil? && !game.away_score.nil?
        if game.home_score > game.away_score
          wins += 1
        elsif game.away_score > game.home_score
          losses += 1
        end
      end
    end

    away_games.find_all_by_year(year).try(:map) do |game|
      if !game.home_score.nil? && !game.away_score.nil?
        if game.home_score > game.away_score
          losses += 1
        elsif game.away_score > game.home_score
          wins += 1
        end
      end
    end

    record = records.find_by_year(year)
    if record.nil?
       Record.create(:team_id => id, :year => year, :wins => wins, :losses => losses)
    else
      record.update_attributes(:wins => wins, :losses => losses)
    end
  end

  def record_formatted(year)
    record = records.find_by_year(year)
    return "(#{record.wins}-#{record.losses})" unless record.nil?
  end
end
