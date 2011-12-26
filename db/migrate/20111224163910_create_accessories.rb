class CreateAccessories < ActiveRecord::Migration
  def change
    create_table :accessories do |t|
      t.string :name
      t.integer :option_id, :references => nil
      t.integer :quantity, :default => 1

      t.timestamps
    end
  end
end
