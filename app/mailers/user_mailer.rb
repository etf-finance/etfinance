require "open-uri"

class UserMailer < ActionMailer::Base

	 def welcome(user)
    @user = user  # Instance variable => available in view

    mail(to: @user.email, subject: 'Welcome to ETF FINANCE')
    # This will render a view in `app/views/user_mailer`!
  end

end
