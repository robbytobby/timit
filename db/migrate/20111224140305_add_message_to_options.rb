class AddMessageToOptions < ActiveRecord::Migration
  def change
    add_column :options, :message, :text
  end
end
