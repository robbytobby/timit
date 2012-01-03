class CreateAccessoriesOptions < ActiveRecord::Migration
  def change
    create_table :accessories_options, :id => false do |t|
      t.references :accessory, :option
    end
    remove_column :accessories, :option_id
  end
end
