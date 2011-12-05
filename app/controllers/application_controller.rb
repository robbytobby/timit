class ApplicationController < ActionController::Base
  protect_from_forgery
  
  private
  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  def store_location
    session[:return_to] = request.env['HTTP_REFERER'] #if request.get? and controller_name != "user_sessions" and controller_name != "sessions"
  end

  def redirect_back_or_default(default, opts = {})
    redirect_to(session[:return_to] || default, opts)
  end


  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message
    redirect_to root_url
  end

end
