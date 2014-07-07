class WinPoolPick < ActiveRecord::Base
  belongs_to :win_pool_league
  belongs_to :user
  belongs_to :team_one, :class_name => "Team", :foreign_key => "team_one_id"
  belongs_to :team_two, :class_name => "Team", :foreign_key => "team_two_id"
  belongs_to :team_three, :class_name => "Team", :foreign_key => "team_three_id"

  validates :user_id, :uniqueness => {:scope => :win_pool_league_id}
  validates :team_one_id, :uniqueness => {:scope => :win_pool_league_id}
  validates :team_two_id, :uniqueness => {:scope => :win_pool_league_id}
  validates :team_three_id, :uniqueness => {:scope => :win_pool_league_id}
  validates :starting_position, :uniqueness => {:scope => :win_pool_league_id}

  attr_accessible :starting_position, :team_one_id, :team_three_id, :team_two_id, :user_id, :win_pool_league_id, :year

  # models
  def teams_full?
    !team_one.nil? && !team_two.nil? && !team_three.nil? ? true : false
  end

  def next_pick
    if team_one.nil?
      return starting_position
    elsif team_two.nil?
      return TEAM_TWO_PICKS[starting_position]
    elsif team_three.nil?
      return TEAM_THREE_PICKS[starting_position]
    end
  end
end
