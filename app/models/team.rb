class Team < ActiveRecord::Base
  has_many :records
  
  attr_accessible :conference, :division, :image, :location, :name
  
  # methods
  def record_formatted(year)
    record = records.find_by_year(year)
    return "(#{record.wins}-#{record.losses})"
  end
end
