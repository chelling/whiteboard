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

      User.all.map do |user|
        pick = user.fooicide_pick_by_game_id(id)
        if !pick.nil?
          if team_id != 0 && pick.try(:team_id) == team_id
            pick.win = true
          else
            pick.win = false
          end
          pick.save
        end
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
end
