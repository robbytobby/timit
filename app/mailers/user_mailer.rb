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

  def sign_up_notification(user, admin = User.find_by_email('christian.wittekindt@physchem.uni-freiburg.de'))
    @user = user
    @to = (User.where(:role => 'admin', :approved => true)).map{|a| a.email }
    mail(:to => @to, :from => Devise.mailer_sender, :subject => t('user_mailer.sign_up_notification.subject'))
  end
end

