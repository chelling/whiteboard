class Team < ActiveRecord::Base
  has_many :records
  
  attr_accessible :conference, :division, :image, :location, :name
end
