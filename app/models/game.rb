class Game < ActiveRecord::Base
  attr_accessible :away_score, :date, :home_score, :location, :week, :year
end
