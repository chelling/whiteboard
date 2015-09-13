task :send_weekly_email => :environment do
  # Remind for fooicide on Saturdays
  if Date.today.strftime('%A') == 'Saturday'
    week = find_week
    User.all.map do |u|
      if u.fooicide_picks.where(year: Date.today.year).size > 0 &&
         u.fooicide_picks.where(year: Date.today.year, week: week).first.nil? &&
         !u.is_eliminated?(Date.today.year)
        UserMailer.fooicide_reminder(u, week).deliver
      end
    end
  end

  # Lines set email Wednesdays
  if Date.today.strftime('%A') == 'Wednesday' && false
    week = find_week
    User.all.map do |u|
      if u.accounts.where(year: Date.today.year).first.try(:amount).to_i > 0
        UserMailer.lines_set(u, week).deliver
      end
    end
  end
end
