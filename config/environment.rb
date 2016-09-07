# Load the rails application
require File.expand_path('../application', __FILE__)

def find_week
  week1 = Time.new(2016, 9, 13)
  @time = Time.now.in_time_zone('Arizona')
  week = (((@time - week1) / (3600 * 24)) / 7).ceil
  return '1' if week <= 0
  return '17' if week >= 17
  return week.to_s
end

# Initialize the rails application
Whiteboard::Application.initialize!
