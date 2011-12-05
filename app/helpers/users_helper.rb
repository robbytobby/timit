module UsersHelper
  def human_roles
    roles = []
    User.roles.each{|r| roles << [t("activerecord.attributes.user.#{r}"), r]}
    roles
  end
end
