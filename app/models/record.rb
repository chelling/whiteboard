class Record < ActiveRecord::Base
  belongs_to :team

  attr_accessor :losses, :team_id, :wins, :year
end
