class CreateOptionGroups < ActiveRecord::Migration
  def change
    create_table :option_groups do |t|
      t.string :name
      t.boolean :exclusive, :default => false
      t.boolean :optional, :default => true

      t.timestamps
    end
  end
end
