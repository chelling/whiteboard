class Share < ActiveRecord::Base
  belongs_to :user
  belongs_to :game
  belongs_to :team

  #attr_accessor :game_id, :team_id, :user_id, :year
end
