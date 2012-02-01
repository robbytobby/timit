class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_locale_from_params
  before_filter :authenticate_user! 
  
  private
  def set_locale_from_params
    if params[:locale]
      if I18n.available_locales.include?(params[:locale].to_sym)
        I18n.locale = params[:locale]
      else
        flash.now[:notice] = "#{params[:locale]} translation not available"
        logger.error flash.now[:notice]
      end
    end
  end
  
  def default_url_options
    {:locale => I18n.locale}
  end

  def after_sign_in_path_for(resource_or_scope)
    if resource_or_scope.is_a?(User) && resource_or_scope.locale
      I18n.locale = resource_or_scope.locale
    end
    super
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  def store_location
    session[:return_to] = request.env['HTTP_REFERER'] #if request.get? and controller_name != "user_sessions" and controller_name != "sessions"
  end

  def redirect_back_or_default(default, opts = {})
    redirect_to(session[:return_to] || default, opts)
  end

  #def wrap_in_transaction
  #  ActiveRecord::Base.transaction do
  #    begin
  #      yield
  #    ensure
  #      raise ActiveRecord::Rollback
  #    end
  #  end
  #end

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = exception.message
    redirect_to root_url
  end

end
