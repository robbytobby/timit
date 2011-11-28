class UserMailer < ActionMailer::Base
  def welcome_email(user, admin)
    @user = user
    mail(:to => user.mail_name, :from  => admin.mail_name, :subject => t('user_mailer.welcome_email.subject') )
  end

  def approval_change_email(user, admin)
    @user = user
    mail(:to => user.mail_name, :from => admin.mail_name, :subject => t('user_mailer.approval_change_email.subject') )
  end

  def destroy_email(user, admin)
    @user = user
    mail(:to => user.mail_name, :from => admin.mail_name, :subject => t('user_mailer.destroy_mail.subject'))
  end
end

