class UsersController < ApplicationController
  before_filter :authenticate_user! 
  before_filter :find_user, :only => [:show, :edit, :update, :destroy, :change_approved]
  before_filter :not_yourself, :only => [:destroy, :change_approved]

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
    @user = User.new(params[:user])

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  def edit
  end

  def create
    @user = User.new(params[:user])
    @user.password = Devise.friendly_token.first(8)

    respond_to do |format|
      if @user.save
        @user.send_welcome_email(current_user)
        format.html { redirect_to users_path, notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to users_path, notice: t('controller.user.update.success') }
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
      format.html { redirect_to users_url }
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
  def find_user
    @user = User.find(params[:id])
  end

  def not_yourself
    notice =  t('controller.users.not_yourself', :action => t('controller.users.actions.' + params[:action]))
    redirect_to users_path, notice: notice  if @user == current_user
  end
end
