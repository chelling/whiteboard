class UserMailer < ActionMailer::Base
  default from: "info.foonation@gmail.com"

  def test
    mail(:to => 'clint.helling@gmail.com', :subject => 'hihi')
  end
end
