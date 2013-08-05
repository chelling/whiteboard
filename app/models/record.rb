class Record < ActiveRecord::Base
  belongs_to :team
  
  attr_accessible :losses, :team_id, :wins, :year
end
