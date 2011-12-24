class RemoveMachineIdFromOptions < ActiveRecord::Migration
  def change
    remove_column :options, :machine_id
  end
end
