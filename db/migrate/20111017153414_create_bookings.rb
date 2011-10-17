class CreateBookings < ActiveRecord::Migration
  def change
    create_table :bookings do |t|
      t.datetime :starts_at
      t.datetime :ends_at
      t.boolean :all_day
      t.integer :user_id
      t.integer :machine_id

      t.timestamps
    end
  end
end
