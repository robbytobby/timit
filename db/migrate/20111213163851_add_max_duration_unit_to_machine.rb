class AddMaxDurationUnitToMachine < ActiveRecord::Migration
  def change
    add_column :machines, :max_duration_unit, :string
  end
end
