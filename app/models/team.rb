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

  def self.team_id_from_string(t)
    if t == 'CHI'
      return Team.find_by_name("Bears").try(:id)
    elsif t == 'DET'
      return Team.find_by_name("Lions").try(:id)
    elsif t == 'GB'
      return Team.find_by_name("Packers").try(:id)
    elsif t == 'MIN'
      return Team.find_by_name("Vikings").try(:id)
    elsif t == 'ATL'
      return Team.find_by_name("Falcons").try(:id)
    elsif t == 'CAR'
      return Team.find_by_name("Panthers").try(:id)
    elsif t == "NO"
      return Team.find_by_name("Saints").try(:id)
    elsif t == 'TB'
      return Team.find_by_name("Buccaneers").try(:id)
    elsif t == 'DAL'
      return Team.find_by_name("Cowboys").try(:id)
    elsif t == 'NYG'
      return Team.find_by_name("Giants").try(:id)
    elsif t == 'PHL'
      return Team.find_by_name("Eagles").try(:id)
    elsif t == 'WAS'
      return Team.find_by_name("Redskins").try(:id)
    elsif t == 'AZ'
      return Team.find_by_name("Cardinals").try(:id)
    elsif t == 'SF'
      return Team.find_by_name("49ers").try(:id)
    elsif t == 'SEA'
      return Team.find_by_name("Seahawks").try(:id)
    elsif t == 'STL'
      return Team.find_by_name("Rams").try(:id)
    elsif t == 'BAL'
      return Team.find_by_name("Ravens").try(:id)
    elsif t == 'CIN'
      return Team.find_by_name("Bengals").try(:id)
    elsif t == 'CLE'
      return Team.find_by_name("Browns").try(:id)
    elsif t == 'PIT'
      return Team.find_by_name("Steelers").try(:id)
    elsif t == 'HOU'
      return Team.find_by_name("Texans").try(:id)
    elsif t == 'IND'
      return Team.find_by_name("Colts").try(:id)
    elsif t == 'JAC'
      return Team.find_by_name("Jaguars").try(:id)
    elsif t == 'TEN'
      return Team.find_by_name("Titans").try(:id)
    elsif t == 'BUF'
      return Team.find_by_name("Bills").try(:id)
    elsif t == 'MIA'
      return Team.find_by_name("Dolphins").try(:id)
    elsif t == 'NE'
      return Team.find_by_name("Patriots").try(:id)
    elsif t == 'NYJ'
      return Team.find_by_name("Jets").try(:id)
    elsif t == 'DEN'
      return Team.find_by_name("Broncos").try(:id)
    elsif t == 'KC'
      return Team.find_by_name("Chiefs").try(:id)
    elsif t == 'OAK'
      return Team.find_by_name("Raiders").try(:id)
    elsif t == 'SD'
      return Team.find_by_name("Chargers").try(:id)
    end
  end
end
