class UserMailer < ActionMailer::Base
  include Devise::Mailers::Helpers

  def welcome_email(user)
    devise_mail(user, :set_password_instructions)
  end
end

