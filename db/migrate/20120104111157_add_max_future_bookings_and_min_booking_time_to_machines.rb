class AddMaxFutureBookingsAndMinBookingTimeToMachines < ActiveRecord::Migration
  def change
    add_column :machines, :max_future_bookings, :integer, :default => 1
    add_column :machines, :min_booking_time, :integer, :default => 1
    add_column :machines, :min_booking_time_unit, :string, :default => 'hour'
  end
end
