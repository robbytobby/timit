class CreateMachinesOptions < ActiveRecord::Migration
  def change
    create_table :machines_options, :id => false do |t|
      t.references :machine, :option
    end
  end
end
