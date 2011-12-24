class AddNeedsTemperatureAndNeedsSampleToMachine < ActiveRecord::Migration
  def change
    add_column :machines, :needs_temperature, :boolean, :default => false
    add_column :machines, :needs_sample, :boolean, :default => false
  end
end
