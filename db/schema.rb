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

ActiveRecord::Schema.define(:version => 20111129090114) do

  create_table "machines", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "",    :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "",    :null => false
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
    t.boolean  "approved",                              :default => false, :null => false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone"
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
    t.index ["machine_id"], :name => "index_bookings_on_machine_id"
    t.index ["user_id"], :name => "index_bookings_on_user_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "bookings_user_id_fkey"
    t.foreign_key ["machine_id"], "machines", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "bookings_machine_id_fkey"
  end

end
