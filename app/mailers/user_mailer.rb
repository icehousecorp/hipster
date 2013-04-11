class UserMailer < ActionMailer::Base
	include Resque::Mailer
  default from: "hipster-notification@icehousecorp.com"

  def alert_email(recipient, message)
  	puts "sending email #{recipient}, #{message}"
  	@message = message;
    mail(:to => recipient, :subject => "Hipster Alert")
  end
end
