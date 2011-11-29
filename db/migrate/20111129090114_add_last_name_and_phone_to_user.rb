class AddLastNameAndPhoneToUser < ActiveRecord::Migration
  def change
    add_column :users, :last_name, :string
    add_column :users, :phone, :string
  end
end
