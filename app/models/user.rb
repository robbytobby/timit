class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :bookings

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

  def active_for_authentication? 
    super && approved? 
  end 
  
  def inactive_message 
    if !approved? 
      :not_approved 
    else 
      super # Use whatever other message 
    end 
  end

  def user_name
    email
  end

  def mail_name
    "#{user_name} <#{email}>"
  end

  def toggle_approved 
    self.approved = !approved
  end

  def send_welcome_email(admin)
    generate_reset_password_token! if should_generate_token?
    UserMailer.welcome_email(self, admin).deliver
  end
end
