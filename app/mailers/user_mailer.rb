class UserMailer < ActionMailer::Base
  default from: "Foo-nation <info.foonation@gmail.com>"

  def win_pool_pick
    User.all.map do |user|
      @win_pool_pick = WinPoolPick.find_by_user_id_and_year_and_win_pool_league_id(user.id, Date.today.year, 1)
      if !@win_pool_pick.nil? && @win_pool_pick.is_current_user_turn?
        mail(:to => user.email, :subject => 'It\'s your turn to pick!')
      end
    end
  end

  def pick_submitted
    mail(:to => 'clint.helling@gmail.com', :subject => 'A pick was submitted')
  end

  def win_pool_draft(user)
    mail(:to => user.email, :subject => 'Win Pool Draft')
  end

  def welcome_back(user)
    mail(:to => user.email, :subject => 'FooNation is back!')
  end

  def weekly_reminder
    User.all.map do |user|
      @year = Time.now.year
      @week = find_week
      @submitted = user.pickem_picks_submitted?(@year, @week)
      if @submitted
        mail(:to => user.email, :subject => 'Don\'t forget to submit your picks (David)')
      end
    end
  end

  def test
    mail(:to => 'clint.helling@gmail.com', :subject => 'hihi')
  end

  def rules_email(user)
    mail(:to => user.email, :subject => 'Foo-nation Games')
  end
end
