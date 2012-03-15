class CreateExclusions < ActiveRecord::Migration
  def change
    create_table :exclusions do |t|
      t.integer :option_id
      t.integer :excluded_option_id, :references => :options

      t.timestamps
    end
  end
end
