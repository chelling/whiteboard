class ThirtyEight < ActiveRecord::Base
  belongs_to :user
  belongs_to :team

  attr_accessor :shares, :team_id, :user_id, :year
end
