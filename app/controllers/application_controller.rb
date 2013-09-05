class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end
  
  def find_week
    week1 = Time.new(2013, 9, 9)
    week2 = Time.new(2013, 9, 16)
    week3 = Time.new(2013, 9, 23)
    week4 = Time.new(2013, 9, 30)
    week5 = Time.new(2013, 10, 7)
    week6 = Time.new(2013, 10, 14)
    week7 = Time.new(2013, 10, 21)
    week8 = Time.new(2013, 10, 28)
    week9 = Time.new(2013, 11, 4)
    week10 = Time.new(2013, 11, 11)
    week11 = Time.new(2013, 11, 18)
    week12 = Time.new(2013, 11, 25)
    week13 = Time.new(2013, 12, 2)
    week14 = Time.new(2013, 12, 9)
    week15 = Time.new(2013, 12, 16)
    week16 = Time.new(2013, 12, 23)
    week17 = Time.new(2013, 12, 29)
    @time = Time.now.in_time_zone('Eastern Time (US & Canada)')
    if @time < week1
      return '1'
    elsif @time > week1 && @time < week2
      return '2'
    elsif @time > week2 && @time < week3
      return '3'
    elsif @time > week3 && @time < week4
      return '4'
    elsif @time > week4 && @time < week5
      return '5'
    elsif @time > week5 && @time < week6
      return '6'
    elsif @time > week6 && @time < week7
      return '7'
    elsif @time > week7 && @time < week8
      return '8'
    elsif @time > week8 && @time < week9
      return '9'
    elsif @time > week9 && @time < week10
      return '10'
    elsif @time > week10 && @time < week11
      return '11'
    elsif @time > week11 && @time < week12
      return '12'
    elsif @time > week12 && @time < week13
      return '13'
    elsif @time > week13 && @time < week14
      return '14'
    elsif @time > week14 && @time < week15
      return '15'
    elsif @time > week15 && @time < week16
      return '16'
    elsif @time > week17 || (@time > week16 && @time < week17)
      return '17'
    end
  end
end
