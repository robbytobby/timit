class AddCommentAndTemperatureAndSampleToBooking < ActiveRecord::Migration
  def change
    add_column :bookings, :comment, :text
    add_column :bookings, :temperature, :integer
    add_column :bookings, :sample, :string
  end
end
