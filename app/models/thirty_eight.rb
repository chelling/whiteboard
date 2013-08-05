class ThirtyEight < ActiveRecord::Base
  belongs_to :user
  belongs_to :team
  
  attr_accessible :shares, :team_id, :user_id, :year
end
