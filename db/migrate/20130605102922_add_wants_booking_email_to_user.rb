class AddWantsBookingEmailToUser < ActiveRecord::Migration
  def change
    add_column :users, :wants_booking_email, :boolean, null: false, default: true
  end
end
