class Game < ActiveRecord::Base
  has_many :pickem_picks
  has_many :fooicide_picks
  belongs_to :away_team, :class_name => "Team"
  belongs_to :home_team, :class_name => "Team"

  after_save :update_pickem_wins
  
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
        puts "Team: #{id}"
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
end
