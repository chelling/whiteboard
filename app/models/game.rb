class Game < ActiveRecord::Base
  belongs_to :away_team, :class_name => "Team"
  belongs_to :home_team, :class_name => "Team"
  has_many :pickem_picks
  has_many :fooicide_picks

  after_save :update_pickem_wins
  after_save :update_fooicide_picks
  after_save :update_team_records
  after_save :update_thirty_eights
  
  attr_accessible :away_score, :date, :home_score, :location, :week, :year, :away_team_id, :home_team_id , :line
  accepts_nested_attributes_for :pickem_picks, :away_team, :home_team

  # methods
  def date_eastern
    date.try(:in_time_zone, 'Eastern Time (US & Canada)')
  end

  def in_progress_or_complete?
      Time.now.in_time_zone('Eastern Time (US & Canada)') - 4 * 60 * 60 > date_eastern
  end
  
  # hooks
  def update_pickem_wins
    team_id = 0
    if !away_score.nil? && !home_score.nil?
      if away_score - home_score > line
        team_id = away_team_id
      elsif away_score - home_score < line
        team_id = home_team_id
      end
      # update all user picks for this game
      User.all.map do |user|
        pick = user.pickem_pick_by_game_id(id)
        if !pick.nil?
          if pick.try(:team_id) == team_id
            pick.win = true
            pick.tie = false
          elsif team_id == 0
            pick.win = false
            pick.tie = true
          else
            pick.win = false
            pick.tie = false
          end
          pick.save
        end
      end
    else
      User.all.map do |user|
        pick = user.pickem_pick_by_game_id(id)
        if !pick.nil?
          pick.win = nil
          pick.tie = nil
          pick.save
        end
      end
    end
  end

  def update_fooicide_picks
    team_id = 0
    if !home_score.nil? && !away_score.nil?
      if home_score > away_score
        team_id = home_team_id
      elsif away_score > home_score
        team_id = away_team_id
      end
    end

    User.all.map do |user|
      pick = user.fooicide_pick_by_game_id(id)
      if !pick.nil?
        if team_id != 0 && pick.try(:team_id) == team_id
          pick.win = true
        elsif team_id != 0
          pick.win = false
        else
          pick.win = nil
        end
        pick.save
      end
    end
  end

  def update_thirty_eights
    if !away_score.nil? && away_score == 38
      thirty_eight = ThirtyEight.find_by_year_and_team_id(year, away_team_id)
      Share.create(:user_id => thirty_eight.user.id, :team_id => away_team_id, :game_id => id, :year => year)
    end

    if !home_score.nil? && home_score == 38
      thirty_eight = ThirtyEight.find_by_year_and_team_id(year, home_team_id)
      Share.create(:user_id => thirty_eight.user.id, :team_id => home_team_id, :game_id => id, :year => year)
    end
  end

  def update_team_records
    away_team.try(:update_records_by_year, year)
    home_team.try(:update_records_by_year, year)
  end

  def self.spread2011
    year = 0
    week = 0
    date = nil
    File.open("#{Rails.root}/public/spread2011.csv").each do |line|
      game = line.split(',')
      # Update the week
      if game.first == 'Week'
        week = game.last
      else
        date = game[0].split('/')
        time = game[1].split(':')
        time[0].to_i == 12 ? hour = time[0].to_i : hour = time[0].to_i + 12
        game_date = DateTime.new(date[2].to_i,date[0].to_i,date[1].to_i,hour,time[1].to_i)
        year = date[2]
        away_team = Team.team_id_from_string(game[2].tr('"',''))
        puts away_team
        home_team = Team.team_id_from_string(game[3].tr('"',''))
        puts home_team
        game_line = game[4]
        david_pick = game[6]
        clint_pick = game[7]
        nic_pick = game[8]
        nick_pick = game[9]
        away_score = game[11]
        home_score = game[12]
        g = Game.create(:year => year.to_i, :week => week.to_i, :home_team_id => home_team, :away_team_id => away_team, :line => game_line.to_f,
                    :date => game_date, :location => Team.find(home_team).location, :home_score => home_score.to_i, :away_score => away_score.to_i)
        if david_pick != ''
          PickemPick.create(:year => year.to_i, :week => week.to_i, :team_id => Team.team_id_from_string(david_pick.tr('"','')), :game_id => g.id, :user_id => 2)
        end
        if clint_pick != ''
          PickemPick.create(:year => year.to_i, :week => week.to_i, :team_id => Team.team_id_from_string(clint_pick.tr('"','')), :game_id => g.id, :user_id => 1)
        end
        if nic_pick != ''
          PickemPick.create(:year => year.to_i, :week => week.to_i, :team_id => Team.team_id_from_string(nic_pick.tr('"','')), :game_id => g.id, :user_id => 6)
        end
        if nick_pick != ''
          PickemPick.create(:year => year.to_i, :week => week.to_i, :team_id => Team.team_id_from_string(nick_pick.tr('"','')), :game_id => g.id, :user_id => 3)
        end
        g.save
      end
    end
  end

  def self.spread2012
    year = 0
    week = 0
    date = nil
    File.open("#{Rails.root}/public/spread2012.csv").each do |line|
      game = line.split(',')
      # Update the week
      if game.first == 'Week'
        week = game.last
      else
        date = game[0].split('/')
        time = game[1].split(':')
        time[0].to_i == 12 ? hour = time[0].to_i : hour = time[0].to_i + 12
        game_date = DateTime.new(date[2].to_i,date[0].to_i,date[1].to_i,hour,time[1].to_i)
        year = date[2]
        away_team = Team.team_id_from_string(game[2].tr('"',''))
        puts away_team
        home_team = Team.team_id_from_string(game[3].tr('"',''))
        puts home_team
        game_line = game[4]
        david_pick = game[7]
        clint_pick = game[8]
        nic_pick = game[9]
        nick_pick = game[10]
        gary_pick = game[11]
        away_score = game[12]
        home_score = game[13]
        g = Game.create(:year => year.to_i, :week => week.to_i, :home_team_id => home_team, :away_team_id => away_team, :line => game_line.to_f,
                        :date => game_date, :location => Team.find(home_team).location, :home_score => home_score.to_i, :away_score => away_score.to_i)
        if david_pick != ''
          PickemPick.create(:year => year.to_i, :week => week.to_i, :team_id => Team.team_id_from_string(david_pick.tr('"','')), :game_id => g.id, :user_id => 2)
        end
        if clint_pick != ''
          PickemPick.create(:year => year.to_i, :week => week.to_i, :team_id => Team.team_id_from_string(clint_pick.tr('"','')), :game_id => g.id, :user_id => 1)
        end
        if nic_pick != ''
          PickemPick.create(:year => year.to_i, :week => week.to_i, :team_id => Team.team_id_from_string(nic_pick.tr('"','')), :game_id => g.id, :user_id => 6)
        end
        if nick_pick != ''
          PickemPick.create(:year => year.to_i, :week => week.to_i, :team_id => Team.team_id_from_string(nick_pick.tr('"','')), :game_id => g.id, :user_id => 3)
        end
        if gary_pick != ''
          PickemPick.create(:year => year.to_i, :week => week.to_i, :team_id => Team.team_id_from_string(gary_pick.tr('"','')), :game_id => g.id, :user_id => 10)
        end
        g.save
      end
    end
  end
end
