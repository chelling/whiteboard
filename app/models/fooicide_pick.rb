class FooicidePick < ActiveRecord::Base
  belongs_to :user
  belongs_to :team
  belongs_to :game
  
  attr_accessible :game_id, :team_id, :user_id, :week, :year, :win
end
