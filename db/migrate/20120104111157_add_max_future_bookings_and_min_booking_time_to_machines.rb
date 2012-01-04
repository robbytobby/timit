class AddMaxFutureBookingsAndMinBookingTimeToMachines < ActiveRecord::Migration
  def change
    add_column :machines, :max_future_bookings, :integer
    add_column :machines, :min_booking_time, :integer
    add_column :machines, :min_booking_time_unit, :string
  end
end
