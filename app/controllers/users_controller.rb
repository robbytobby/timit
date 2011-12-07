class UsersController < ApplicationController
  before_filter :authenticate_user! 
  load_and_authorize_resource
  before_filter :delete_blank_password, :only => :update

  def index
    @users = User.order(:id)

    respond_to do |format|
      format.html
      format.json { render json: @users }
    end
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  def edit
  end

  def create
    @user.password = Devise.friendly_token.first(8)
    @user.toggle_approved

    respond_to do |format|
      if @user.save
        @user.send_welcome_email(current_user)
        format.html { redirect_to users_path, notice: t('controller.success.create', :thing => t('activerecord.models.user')) }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    params[:user].delete(:password)
    params[:user].delete(:role) if cannot? :change_role, @user
    change_role(params[:user][:role]) if params[:user][:role]

    respond_to do |format|
      if @user.update_attributes(params[:user])
        sign_in @user, :bypass => true if params[:user][:password]
        format.html { redirect_to users_path, notice: t('controller.success.update', :thing => t('activerecord.models.user')) }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user.destroy
    UserMailer.destroy_email(@user, current_user).deliver

    respond_to do |format|
      format.html do
        if @user == current_user
          redirect_to new_user_session_url, notice: t('controller.users.destroy_self.success')
        else
          redirect_to users_url, notice: t('controller.success.destroy', :thing => t('activerecord.models.user')) 
        end
      end
      format.json { head :ok }
    end
  end

  def change_approved
    @user.toggle_approved
    
    respond_to do |format|
      path = "controller.users.#{@user.approved? ? 'activation' : 'deactivation'}"
      if @user.save
        UserMailer.approval_change_email(@user, current_user).deliver
        #TODO: I18n
        format.html { redirect_to users_path, notice: t( path + '.success', :name => @user.user_name) }
        format.json { head :ok }
      else
        format.html { redirect_to users_path, notice: t( path + '.failure', :name => @user.user_name) }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  protected
  def change_role(role)
    @user.role = role
  end

  def delete_blank_password
    if params[:user][:password].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end
  end
end
