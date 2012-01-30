class UserMailer < ActionMailer::Base
  default :from => Devise.mailer_sender

  def welcome_email(user, admin)
    @user = user
    mail(:to => user.mail_name, :reply_to => admin.mail_name, :subject => t('user_mailer.welcome_email.subject') )
  end

  def approval_change_email(user, admin)
    @user = user
    @bcc = (User.where(:role => 'admin', :approved => true)).map{|a| a.email }
    mail(:to => user.mail_name, :reply_to => admin.mail_name, :bcc => @bcc, :subject => t('user_mailer.approval_change_email.subject') )
  end

  def destroy_email(user, admin)
    @user = user
    mail(:to => user.mail_name, :reply_to => admin.mail_name, :subject => t('user_mailer.destroy_email.subject'))
  end

  def sign_up_notification(user)
    @user = user
    @to = (User.where(:role => 'admin', :approved => true)).map{|a| a.email }
    mail(:to => @to, :subject => t('user_mailer.sign_up_notification.subject'))
  end

  def booking_updated_notification(current_user, booking, old_booking)
    @booking = booking
    @old_booking = old_booking
    @current_user = current_user
    mail(:to => booking.user.mail_name, :reply_to => current_user.mail_name, :subject => t('user_mailer.booking_updated_notification.subject'))
  end

  def booking_deleted_notification(current_user, booking)
    @booking = booking
    @current_user = current_user
    mail(:to => booking.user.mail_name, :reply_to => current_user.mail_name, :subject => t('user_mailer.booking_deleted_notification.subject'))
  end
end

