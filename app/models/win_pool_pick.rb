class WinPoolPick < ActiveRecord::Base
  belongs_to :win_pool_league
  belongs_to :user
  belongs_to :team_one, :class_name => "Team", :foreign_key => "team_one_id"
  belongs_to :team_two, :class_name => "Team", :foreign_key => "team_two_id"
  belongs_to :team_three, :class_name => "Team", :foreign_key => "team_three_id"

  validates :user_id, :uniqueness => {:scope => :win_pool_league_id}
  validates :starting_position, :uniqueness => {:scope => :win_pool_league_id}

  # models
  def teams_full?
    team_one.present? || team_two.present? || team_three.present?
  end

  def is_current_user_turn?
    if self.teams_full?
      return false
    end

    current_pick = WinPoolLeague.find_by(id: self.win_pool_league_id).get_current_pick(year)

    if current_pick == self.next_pick
      return true
    else
      return false
    end
  end

  def next_pick
    if team_one.nil?
      return starting_position
    elsif team_two.nil?
      return TEAM_TWO_PICKS[starting_position-1]
    elsif team_three.nil?
      return TEAM_THREE_PICKS[starting_position-1]
    end
  end
end
