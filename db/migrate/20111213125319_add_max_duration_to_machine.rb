class AddMaxDurationToMachine < ActiveRecord::Migration
  def change
    add_column :machines, :max_duration, :integer
  end
end
