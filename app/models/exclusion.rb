class Exclusion < ActiveRecord::Base
  belongs_to :option
  belongs_to :excluded_option, :class_name => 'Option'
  after_create :create_inverse_relation
  after_destroy :destroy_inverse_relation

  def create_inverse_relation
    obj = Exclusion.where(:option_id => excluded_option_id, :excluded_option_id => option_id)
    Exclusion.create(:option_id => excluded_option_id, :excluded_option_id => option_id) if obj.blank?
  end

  def destroy_inverse_relation
    obj = Exclusion.where(:option_id => excluded_option_id, :excluded_option_id => option_id)
    obj.destroy_all if obj.any?
  end
end
