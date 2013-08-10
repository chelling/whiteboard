class Team < ActiveRecord::Base
  has_many :records
  has_many :thirty_eights
  
  attr_accessible :conference, :division, :image, :location, :name
  
  # methods
  def record_formatted(year)
    record = records.find_by_year(year)
    return "(#{record.wins}-#{record.losses})" unless record.nil?
  end
end
