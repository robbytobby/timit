class CreateOptions < ActiveRecord::Migration
  def change
    create_table :options do |t|
      t.integer :machine_id
      t.string :name

      t.timestamps
    end
  end
end
