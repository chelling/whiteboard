# Load the rails application
require File.expand_path('../application', __FILE__)

def find_week
  week1 = Time.new(2015, 9, 16)
  @time = Time.now.in_time_zone('Arizona')
  week = (((@time - week1) / (3600 * 24)) / 7).to_i
  return '1' if week <= 0
  return '17' if week >= 17
  return week
end

# Initialize the rails application
Whiteboard::Application.initialize!
