class User < ActiveRecord::Base
  strip_attributes
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :timeoutable, :recoverable, :rememberable, :trackable, :validatable
  has_many :bookings, :dependent => :destroy
  has_and_belongs_to_many :default_machines, :class_name => "Machine"

  # Setup accessible (or protected) attributes for your model
  attr_accessible :first_name, :last_name, :phone, :email, :password, :password_confirmation, :remember_me, :locale, :default_machine_ids
  validates_presence_of :first_name, :last_name, :phone, :role
  validates :phone, :format => /^\d[\d -\/]*\d$/
  validate :role_defined?
  @@ROLES = [ "unprivileged", "teaching", "admin" ]

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

  def user_name(format = :long)
    if format == :long
      name
    elsif format == :short
      first_name[0] + '. ' + last_name[0..15]
    elsif format == :shorter
      first_name[0] + '. ' + last_name[0..11]
    else
      raise "unknown format #{format} for user_name"
    end
  end

  def name
    first_name + ' ' + last_name
  end

  def mail_name
    "#{user_name} <#{email}>"
  end

  def toggle_approved 
    self.approved = !approved
  end

  def send_welcome_email(admin)
    generate_reset_password_token! if should_generate_reset_token?
    UserMailer.welcome_email(self, admin).deliver
  end
  
  def role?(test)
    role == test.to_s
  end

  def self.roles
    @@ROLES
  end

  private
  def role_defined?
    errors.add(:role, :undefined) unless @@ROLES.include?(role)
  end
end
