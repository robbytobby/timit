class RegistrationsController < Devise::RegistrationsController
  skip_before_filter :authenticate_user!
  after_filter :inform_admin, :only => :create
  protected

  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end

  def inform_admin
    user = User.find_by_email(@user.email)
    UserMailer.sign_up_notification(user).deliver if user
  end

end
