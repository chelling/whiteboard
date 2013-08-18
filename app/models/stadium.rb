class Stadium < ActiveRecord::Base
  belongs_to :team

  attr_accessible :grass_type, :location, :stadium_type, :time_zone, :name, :team_id
end
