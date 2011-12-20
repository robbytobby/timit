class CreateBookingOption < ActiveRecord::Migration
  def change
    create_table :bookings_options, :id => false do |t|
      t.references :booking, :option
    end
  end
end
