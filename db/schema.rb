# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120103150258) do

  create_table "accessories", :force => true do |t|
    t.string   "name"
    t.integer  "quantity",   :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "option_groups", :force => true do |t|
    t.string   "name"
    t.boolean  "exclusive",  :default => false
    t.boolean  "optional",   :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "options", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "option_group_id"
    t.text     "message"
    t.index ["option_group_id"], :name => "index_options_on_option_group_id"
    t.foreign_key ["option_group_id"], "option_groups", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "options_option_group_id_fkey"
  end

  create_table "accessories_options", :id => false, :force => true do |t|
    t.integer "accessory_id"
    t.integer "option_id"
    t.index ["accessory_id"], :name => "index_accessories_options_on_accessory_id"
    t.index ["option_id"], :name => "index_accessories_options_on_option_id"
    t.foreign_key ["accessory_id"], "accessories", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "accessories_options_accessory_id_fkey"
    t.foreign_key ["option_id"], "options", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "accessories_options_option_id_fkey"
  end

  create_table "machines", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "max_duration"
    t.string   "max_duration_unit"
    t.boolean  "needs_temperature", :default => false
    t.boolean  "needs_sample",      :default => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "",             :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "",             :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "approved",                              :default => false,          :null => false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone"
    t.string   "role",                                  :default => "unprivileged", :null => false
    t.index ["email"], :name => "index_users_on_email", :unique => true
    t.index ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  end

  create_table "bookings", :force => true do |t|
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.boolean  "all_day"
    t.integer  "user_id"
    t.integer  "machine_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "comment"
    t.integer  "temperature"
    t.string   "sample"
    t.index ["machine_id"], :name => "index_bookings_on_machine_id"
    t.index ["user_id"], :name => "index_bookings_on_user_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "bookings_user_id_fkey"
    t.foreign_key ["machine_id"], "machines", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "bookings_machine_id_fkey"
  end

  create_table "bookings_options", :id => false, :force => true do |t|
    t.integer "booking_id"
    t.integer "option_id"
    t.index ["booking_id"], :name => "index_bookings_options_on_booking_id"
    t.index ["option_id"], :name => "index_bookings_options_on_option_id"
    t.foreign_key ["booking_id"], "bookings", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "bookings_options_booking_id_fkey"
    t.foreign_key ["option_id"], "options", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "bookings_options_option_id_fkey"
  end

  create_table "machines_options", :id => false, :force => true do |t|
    t.integer "machine_id"
    t.integer "option_id"
    t.index ["machine_id"], :name => "index_machines_options_on_machine_id"
    t.index ["option_id"], :name => "index_machines_options_on_option_id"
    t.foreign_key ["machine_id"], "machines", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "machines_options_machine_id_fkey"
    t.foreign_key ["option_id"], "options", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "machines_options_option_id_fkey"
  end

end
