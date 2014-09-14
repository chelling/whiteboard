task :send_weekly_email => :environment do
  # Remind for fooicide on Saturdays
  if Date.today.strftime('%A') == 'Saturday'
    week = find_week
    User.all.map do |u|
      if u.fooicide_picks.size > 0 && u.fooicide_picks.find_by_year_and_week(Date.today.year, week).nil? &&
                                      !u.is_eliminated?(Date.today.year)
        UserMailer.fooicide_reminder(u, week).deliver
      end
    end
  end

  # Lines set email Wednesdays
  if Date.today.strftime('%A') == 'Wednesday'
    week = find_week
    User.all.map do |u|
      if u.accounts.find_by_year(Date.today.year).try(:amount) > 0
        UserMailer.lines_set(u, week).deliver
      end
    end
  end
end