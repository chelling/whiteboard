class Team < ActiveRecord::Base
  has_many :records
  has_many :thirty_eights
  has_many :home_games, :foreign_key => "home_team_id", :class_name => "Game", :primary_key => "id"
  has_many :away_games, :foreign_key => "away_team_id", :class_name => "Game", :primary_key => "id"
  has_one :stadium
  has_many :win_pool_first_teams, :foreign_key => "team_one_id", :class_name => "WinPoolPick"
  has_many :win_pool_second_teams, :foreign_key => "team_two_id", :class_name => "WinPoolPick"
  has_many :win_pool_third_teams, :foreign_key => "team_three_id", :class_name => "WinPoolPick"

  #attr_accessor :conference, :division, :image, :location, :name
  
  # methods
  def win_pools
    win_pool_first_teams + win_pool_second_teams + win_pool_third_teams
  end

  def update_records_by_year(year)
    wins = 0
    losses = 0
    home_games.where(year: year).try(:map) do |game|
      if !game.home_score.nil? && !game.away_score.nil?
        if game.home_score > game.away_score
          wins += 1
        elsif game.away_score > game.home_score
          losses += 1
        end
      end
    end

    away_games.where(year: year).try(:map) do |game|
      if !game.home_score.nil? && !game.away_score.nil?
        if game.home_score > game.away_score
          losses += 1
        elsif game.away_score > game.home_score
          wins += 1
        end
      end
    end

    record = records.find_by(year: year)
    if record.nil?
       Record.create(:team_id => id, :year => year, :wins => wins, :losses => losses)
    else
      record.update_attributes(:wins => wins, :losses => losses)
    end
  end

  def record_formatted(year)
    record = records.find_by(year: year)
    return "(#{record.wins}-#{record.losses})" unless record.nil?
  end

  def wins_by_year(year)
    wins = records.find_by(year: year).try(:wins)
    wins.nil? ? 0 : wins
  end

  def self.team_id_from_string(t)
    if t == 'CHI'
      return Team.find_by(name: "Bears").try(:id)
    elsif t == 'DET'
      return Team.find_by(name: "Lions").try(:id)
    elsif t == 'GB'
      return Team.find_by(name: "Packers").try(:id)
    elsif t == 'MIN'
      return Team.find_by(name: "Vikings").try(:id)
    elsif t == 'ATL'
      return Team.find_by(name: "Falcons").try(:id)
    elsif t == 'CAR'
      return Team.find_by(name: "Panthers").try(:id)
    elsif t == 'NO'
      return Team.find_by(name: "Saints").try(:id)
    elsif t == 'TB'
      return Team.find_by(name: "Buccaneers").try(:id)
    elsif t == 'DAL'
      return Team.find_by(name: "Cowboys").try(:id)
    elsif t == 'NYG'
      return Team.find_by(name: "Giants").try(:id)
    elsif t == 'PHL' || t == 'PHI'
      return Team.find_by(name: "Eagles").try(:id)
    elsif t == 'WAS'
      return Team.find_by(name: "Redskins").try(:id)
    elsif t == 'AZ' || t == 'ARI'
      return Team.find_by(name: "Cardinals").try(:id)
    elsif t == 'SF'
      return Team.find_by(name: "49ers").try(:id)
    elsif t == 'SEA'
      return Team.find_by(name: "Seahawks").try(:id)
    elsif t == 'STL'
      return Team.find_by(name: "Rams").try(:id)
    elsif t == 'BAL'
      return Team.find_by(name: "Ravens").try(:id)
    elsif t == 'CIN'
      return Team.find_by(name: "Bengals").try(:id)
    elsif t == 'CLE'
      return Team.find_by(name: "Browns").try(:id)
    elsif t == 'PIT'
      return Team.find_by(name: "Steelers").try(:id)
    elsif t == 'HOU'
      return Team.find_by(name: "Texans").try(:id)
    elsif t == 'IND'
      return Team.find_by(name: "Colts").try(:id)
    elsif t == 'JAC' || t == 'JAX'
      return Team.find_by(name: "Jaguars").try(:id)
    elsif t == 'TEN'
      return Team.find_by(name: "Titans").try(:id)
    elsif t == 'BUF'
      return Team.find_by(name: "Bills").try(:id)
    elsif t == 'MIA'
      return Team.find_by(name: "Dolphins").try(:id)
    elsif t == 'NE'
      return Team.find_by(name: "Patriots").try(:id)
    elsif t == 'NYJ'
      return Team.find_by(name: "Jets").try(:id)
    elsif t == 'DEN'
      return Team.find_by(name: "Broncos").try(:id)
    elsif t == 'KC'
      return Team.find_by(name: "Chiefs").try(:id)
    elsif t == 'OAK'
      return Team.find_by(name: "Raiders").try(:id)
    elsif t == 'SD'
      return Team.find_by(name: "Chargers").try(:id)
    end
  end
end
