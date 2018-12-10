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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_10_29_163235) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "customers", force: :cascade do |t|
    t.string "last_name"
    t.string "first_name"
    t.string "email"
    t.string "company"
    t.string "phone"
    t.text "address1"
    t.text "address2"
    t.string "city"
    t.string "state"
    t.string "postal_code"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
  end

  create_table "employees", force: :cascade do |t|
    t.string "last_name"
    t.string "first_name"
    t.string "email"
    t.string "avatar"
    t.string "job_title"
    t.string "department"
    t.string "phone"
    t.text "address1"
    t.text "address2"
    t.string "city"
    t.string "state"
    t.string "postal_code"
    t.string "country"
    t.bigint "manager_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "region_id"
    t.index ["manager_id"], name: "index_employees_on_manager_id"
    t.index ["region_id"], name: "index_employees_on_region_id"
  end

  create_table "order_details", force: :cascade do |t|
    t.bigint "order_id"
    t.bigint "product_id"
    t.decimal "quantity", precision: 17, scale: 2
    t.decimal "unit_price", precision: 17, scale: 2
    t.decimal "discount", precision: 17, scale: 2
    t.string "status"
    t.datetime "date_allocated"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_details_on_order_id"
    t.index ["product_id"], name: "index_order_details_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "employee_id"
    t.bigint "customer_id"
    t.datetime "order_date"
    t.datetime "shipped_date"
    t.string "ship_name"
    t.text "ship_address1"
    t.text "ship_address2"
    t.string "ship_city"
    t.string "ship_state"
    t.string "ship_postal_code"
    t.string "ship_country"
    t.decimal "shipping_fee", precision: 17, scale: 2
    t.string "payment_type"
    t.datetime "paid_date"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "num"
    t.bigint "region_id"
    t.bigint "referred_by_id"
    t.index ["customer_id"], name: "index_orders_on_customer_id"
    t.index ["employee_id"], name: "index_orders_on_employee_id"
    t.index ["referred_by_id"], name: "index_orders_on_referred_by_id"
    t.index ["region_id"], name: "index_orders_on_region_id"
  end

  create_table "product_variations", force: :cascade do |t|
    t.bigint "product_id"
    t.string "description"
    t.string "code"
    t.string "color"
    t.string "size"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_product_variations_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "description"
    t.decimal "list_price", precision: 17, scale: 2
    t.integer "target_level"
    t.integer "reorder_level"
    t.integer "minimum_reorder_quantity"
    t.string "quantity_per_unit"
    t.boolean "discounted"
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "regions", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jti", null: false
    t.bigint "employee_id"
    t.bigint "customer_id"
    t.string "role"
    t.index ["customer_id"], name: "index_users_on_customer_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["employee_id"], name: "index_users_on_employee_id"
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "employees", "employees", column: "manager_id"
  add_foreign_key "employees", "regions"
  add_foreign_key "order_details", "orders"
  add_foreign_key "order_details", "products"
  add_foreign_key "orders", "customers"
  add_foreign_key "orders", "customers", column: "referred_by_id"
  add_foreign_key "orders", "employees"
  add_foreign_key "orders", "regions"
  add_foreign_key "product_variations", "products"
  add_foreign_key "users", "customers"
  add_foreign_key "users", "employees"
end
