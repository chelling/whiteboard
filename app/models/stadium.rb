class Stadium < ActiveRecord::Base
  belongs_to :team

  #attr_accessor :grass_type, :location, :stadium_type, :time_zone, :name, :team_id
end
