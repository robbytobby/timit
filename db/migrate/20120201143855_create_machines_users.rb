class CreateMachinesUsers < ActiveRecord::Migration
  def change
    create_table :machines_users, :id => false do |t|
      t.references :machine, :user
    end
  end
end
