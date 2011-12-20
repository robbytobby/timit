class AddOptionGroupIdToOptions < ActiveRecord::Migration
  def change
    add_column :options, :option_group_id, :integer
  end
end
