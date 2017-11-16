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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171115140019) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_item_prices", force: :cascade do |t|
    t.integer  "account_id"
    t.integer  "item_id"
    t.decimal  "price",      precision: 10, scale: 2,                 null: false
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.boolean  "migrated",                            default: false
  end

  create_table "account_payment_services", force: :cascade do |t|
    t.text    "name"
    t.text    "service_id"
    t.integer "account_id"
  end

  create_table "accounts", force: :cascade do |t|
    t.integer "user_id"
    t.text    "account_type"
    t.text    "name"
    t.text    "quickbooks_id"
    t.text    "number"
    t.text    "email"
    t.boolean "active"
    t.integer "group_id"
    t.float   "credit_limit",             default: 0.0
    t.integer "credit_terms"
    t.boolean "credit_hold",              default: true
    t.text    "bill_to_email"
    t.boolean "is_taxable"
    t.integer "sales_rep_id"
    t.boolean "replace_items",            default: false, null: false
    t.integer "subscription_week_day"
    t.integer "subscription_month_day"
    t.integer "subscription_quarter_day"
  end

  create_table "addresses", force: :cascade do |t|
    t.integer "account_id"
    t.text    "address_1"
    t.text    "address_2"
    t.text    "city"
    t.text    "state"
    t.text    "zip"
    t.text    "phone"
    t.text    "fax"
    t.boolean "main",       default: false
    t.text    "name"
  end

  create_table "assets", force: :cascade do |t|
    t.text     "type"
    t.integer  "attachment_width"
    t.integer  "attachment_height"
    t.integer  "attachment_file_size"
    t.integer  "position"
    t.text     "attachment_content_type"
    t.text     "attachment_file_name"
    t.datetime "attachment_updated_at"
    t.text     "alt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "attachable_id"
    t.text     "attachable_type"
  end

  create_table "bins", force: :cascade do |t|
    t.text    "name"
    t.text    "_type"
    t.integer "warehouse_id"
  end

  create_table "brands", force: :cascade do |t|
    t.text     "name"
    t.boolean  "active"
    t.boolean  "preferred"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "prefix"
  end

  create_table "categories", force: :cascade do |t|
    t.integer "parent_id"
    t.integer "menu_id"
    t.text    "name"
    t.text    "slug"
    t.text    "description"
    t.boolean "show_in_menu"
    t.boolean "active"
    t.integer "position"
  end

  add_index "categories", ["id"], name: "category_id_ix", using: :btree
  add_index "categories", ["parent_id"], name: "category_parent_id_ix", using: :btree

  create_table "charges", force: :cascade do |t|
    t.integer "account_id"
    t.integer "payment_plan_id"
    t.integer "invoice_id"
    t.float   "line_number"
    t.float   "amount"
    t.float   "quantity"
    t.date    "from_date"
    t.date    "to_date"
    t.text    "description"
  end

  create_table "contacts", force: :cascade do |t|
    t.integer "account_id"
    t.integer "user_id"
    t.text    "number"
    t.text    "first_name"
    t.text    "last_name"
    t.text    "email"
    t.text    "phone"
  end

  create_table "credit_cards", force: :cascade do |t|
    t.integer "account_payment_service_id"
    t.text    "service_card_id"
    t.text    "expiration"
    t.text    "last_4"
    t.text    "card_type"
    t.text    "unique_number_identifier"
    t.text    "cardholder_name"
  end

  create_table "discount_code_effects", force: :cascade do |t|
    t.float   "amount"
    t.float   "percent"
    t.boolean "shipping"
    t.integer "quantity"
    t.integer "item_id"
    t.integer "appliable_id"
    t.text    "appliable_type"
    t.integer "discount_code_id"
    t.text    "name"
  end

  create_table "discount_code_rules", force: :cascade do |t|
    t.integer "quantity"
    t.float   "amount"
    t.integer "requirable_id"
    t.text    "requirable_type"
    t.integer "discount_code_id"
    t.text    "user_appliable_type"
    t.integer "user_appliable_id"
  end

  create_table "discount_codes", force: :cascade do |t|
    t.text    "code"
    t.integer "times_of_use"
    t.boolean "automatic",    default: false
  end

  create_table "email_deliveries", force: :cascade do |t|
    t.text     "addressable_type"
    t.integer  "addressable_id"
    t.text     "to_email"
    t.text     "body"
    t.text     "eventable_type"
    t.integer  "eventable_id"
    t.datetime "failed_at"
    t.datetime "delivered_at"
    t.datetime "opened_at"
  end

  create_table "equipment", force: :cascade do |t|
    t.integer "account_id"
    t.integer "contact_id"
    t.integer "payment_plan_id"
    t.text    "number"
    t.text    "serial"
    t.integer "make_id"
    t.integer "model_id"
    t.text    "location"
    t.boolean "is_managed",      default: false
  end

  create_table "equipment_alerts", force: :cascade do |t|
    t.integer  "equipment_id"
    t.integer  "order_line_item_id"
    t.text     "alert_identification"
    t.text     "alert_type"
    t.text     "supply_type"
    t.text     "supply_color"
    t.text     "supply_part_number"
    t.integer  "supply_level"
    t.text     "equipment_serial"
    t.text     "equipment_asset_id"
    t.text     "equipment_make_model"
    t.text     "equipment_mac_address"
    t.text     "equipment_ip_address"
    t.text     "equipment_group_name"
    t.text     "equipment_location"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",                default: true, null: false
  end

  create_table "equipment_items", force: :cascade do |t|
    t.integer  "equipment_id"
    t.integer  "item_id"
    t.text     "supply_type"
    t.text     "supply_color"
    t.integer  "priority"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.text     "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.text     "scope"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "group_item_prices", force: :cascade do |t|
    t.integer  "group_id"
    t.integer  "item_id"
    t.decimal  "price",      precision: 10, scale: 2,                 null: false
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "migrated",                            default: false
  end

  add_index "group_item_prices", ["group_id"], name: "index_group_item_prices_on_group_id", using: :btree
  add_index "group_item_prices", ["item_id"], name: "index_group_item_prices_on_item_id", using: :btree

  create_table "groups", force: :cascade do |t|
    t.text     "group_type"
    t.text     "name"
    t.text     "slug"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "import_histories", force: :cascade do |t|
    t.integer  "nb_imported"
    t.integer  "nb_failed"
    t.integer  "nb_in_queue"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "is_processing", default: 0
    t.text     "failed_lines",  default: ""
    t.integer  "nb_last_id"
  end

  create_table "inventories", force: :cascade do |t|
    t.integer  "item_id",         null: false
    t.integer  "qty_on_hand"
    t.integer  "qty_sold"
    t.integer  "qty_shipped"
    t.integer  "qty_ordered"
    t.integer  "qty_received"
    t.integer  "qty_backordered"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "bin_id"
  end

  create_table "inventory_transactions", force: :cascade do |t|
    t.integer  "inv_transaction_id",               null: false
    t.text     "inv_transaction_type",             null: false
    t.integer  "quantity",             default: 0, null: false
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "inventory_id"
  end

  create_table "invoice_payment_applications", force: :cascade do |t|
    t.integer "payment_id"
    t.integer "invoice_id"
  end

  add_index "invoice_payment_applications", ["invoice_id"], name: "index_invoice_payment_applications_on_invoice_id", using: :btree
  add_index "invoice_payment_applications", ["payment_id"], name: "index_invoice_payment_applications_on_payment_id", using: :btree

  create_table "invoices", force: :cascade do |t|
    t.integer  "account_id"
    t.text     "number"
    t.date     "date"
    t.float    "total"
    t.integer  "order_id"
    t.datetime "due_date"
  end

  create_table "item_categories", force: :cascade do |t|
    t.integer "category_id"
    t.integer "item_id"
  end

  add_index "item_categories", ["category_id"], name: "item_category_category_id_ix", using: :btree
  add_index "item_categories", ["item_id"], name: "item_category_item_id_ix", using: :btree

  create_table "item_item_lists", force: :cascade do |t|
    t.integer "item_id"
    t.integer "item_list_id"
  end

  add_index "item_item_lists", ["item_id"], name: "index_item_item_lists_on_item_id", using: :btree
  add_index "item_item_lists", ["item_list_id"], name: "index_item_item_lists_on_item_list_id", using: :btree

  create_table "item_lists", force: :cascade do |t|
    t.text    "name"
    t.integer "user_id"
  end

  create_table "item_properties", force: :cascade do |t|
    t.integer "item_id"
    t.text    "key"
    t.text    "value"
    t.integer "order"
    t.boolean "active"
    t.text    "type",    default: "Specification"
  end

  create_table "item_references", force: :cascade do |t|
    t.integer  "original_item_id"
    t.integer  "replacement_item_id"
    t.text     "original_uom"
    t.text     "repacement_uom"
    t.text     "original_uom_qty"
    t.text     "replacement_uom_qty"
    t.text     "comments"
    t.text     "match_type"
    t.text     "xref_type"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "item_types", force: :cascade do |t|
    t.text "name"
    t.text "description"
  end

  create_table "item_vendor_prices", force: :cascade do |t|
    t.integer  "item_id"
    t.integer  "vendor_id"
    t.decimal  "price",              precision: 10, scale: 2, null: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.text     "vendor_item_number"
  end

  create_table "items", force: :cascade do |t|
    t.integer  "item_type_id"
    t.integer  "category_id"
    t.integer  "model_id"
    t.boolean  "is_serialized"
    t.text     "number",                                                          null: false
    t.text     "name"
    t.text     "slug"
    t.text     "description"
    t.decimal  "price",                   precision: 10, scale: 2
    t.decimal  "sale_price",              precision: 10, scale: 2
    t.decimal  "cost_price",              precision: 10, scale: 2
    t.float    "weight"
    t.float    "height"
    t.float    "width"
    t.float    "length"
    t.datetime "created_at",                                                      null: false
    t.datetime "updated_at",                                                      null: false
    t.integer  "brand_id"
    t.boolean  "active",                                           default: true, null: false
    t.decimal  "list_price",              precision: 10, scale: 2
    t.boolean  "green_indicator"
    t.boolean  "recycle_indicator"
    t.boolean  "small_package_indicator"
    t.text     "assembly_code"
    t.text     "non_returnable_code"
  end

  add_index "items", ["id"], name: "item_id_ix", using: :btree

  create_table "jobs", force: :cascade do |t|
    t.text     "job_name"
    t.text     "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "line_item_fulfillments", force: :cascade do |t|
    t.integer  "order_line_item_id"
    t.integer  "invoice_id"
    t.integer  "quantity_fulfilled"
    t.datetime "date"
  end

  create_table "line_item_returns", force: :cascade do |t|
    t.integer "order_line_item_id"
    t.integer "return_authorization_id"
    t.integer "quantity"
    t.integer "bin_id"
  end

  create_table "line_item_shipments", force: :cascade do |t|
    t.integer  "order_line_item_id"
    t.integer  "shipment_id"
    t.integer  "quantity_shipped"
    t.datetime "date"
    t.integer  "bin_id"
  end

  add_index "line_item_shipments", ["id"], name: "line_item_shipment_id_ix", using: :btree
  add_index "line_item_shipments", ["order_line_item_id"], name: "line_item_shipment_order_line_item_id_ix", using: :btree
  add_index "line_item_shipments", ["shipment_id"], name: "line_item_shipment_shipment_id_ix", using: :btree

  create_table "machine_model_items", force: :cascade do |t|
    t.integer  "machine_model_id"
    t.integer  "item_id"
    t.text     "supply_type"
    t.text     "supply_color"
    t.integer  "priority"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "makes", force: :cascade do |t|
    t.text     "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "meter_groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "meter_readings", force: :cascade do |t|
    t.integer "meter_id"
    t.float   "display"
    t.text    "source"
    t.boolean "is_valid"
    t.boolean "is_estimate"
  end

  create_table "meters", force: :cascade do |t|
    t.integer "equipment_id"
    t.text    "meter_type"
  end

  create_table "models", force: :cascade do |t|
    t.integer  "make_id"
    t.text     "number"
    t.text     "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "order_discount_codes", force: :cascade do |t|
    t.integer "discount_code_id"
    t.integer "order_id"
  end

  create_table "order_line_items", force: :cascade do |t|
    t.integer  "order_id"
    t.integer  "order_line_number"
    t.integer  "item_id"
    t.float    "quantity"
    t.decimal  "price",              precision: 10, scale: 2,             null: false
    t.float    "discount"
    t.text     "description"
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.integer  "quantity_canceled"
    t.integer  "quantity_shipped",                            default: 0
    t.integer  "quantity_fulfilled",                          default: 0
    t.integer  "quantity_returned"
  end

  add_index "order_line_items", ["id"], name: "order_line_item_id_ix", using: :btree
  add_index "order_line_items", ["item_id"], name: "order_line_item_item_id_ix", using: :btree
  add_index "order_line_items", ["order_id"], name: "order_line_item_order_id_ix", using: :btree

  create_table "order_payment_applications", force: :cascade do |t|
    t.integer  "payment_id"
    t.integer  "order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "applied_amount", precision: 10, scale: 2, default: 0.0
  end

  add_index "order_payment_applications", ["order_id"], name: "index_order_payment_applications_on_order_id", using: :btree
  add_index "order_payment_applications", ["payment_id"], name: "index_order_payment_applications_on_payment_id", using: :btree

  create_table "order_shipping_methods", force: :cascade do |t|
    t.integer  "order_id"
    t.integer  "shipping_method_id"
    t.decimal  "amount",             precision: 10, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_tax_rates", force: :cascade do |t|
    t.integer  "order_id"
    t.integer  "tax_rate_id"
    t.decimal  "amount",      precision: 10, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orders", force: :cascade do |t|
    t.text     "number"
    t.integer  "account_id"
    t.integer  "contact_id"
    t.integer  "sales_rep_id"
    t.datetime "date"
    t.datetime "due_date"
    t.datetime "submitted_at"
    t.boolean  "locked"
    t.text     "po_number"
    t.text     "ip_address"
    t.text     "ship_to_account_name"
    t.text     "ship_to_address_1"
    t.text     "ship_to_address_2"
    t.text     "ship_to_attention"
    t.text     "ship_to_city"
    t.text     "ship_to_state"
    t.text     "ship_to_zip"
    t.text     "ship_to_phone"
    t.text     "bill_to_account_name"
    t.text     "bill_to_address_1"
    t.text     "bill_to_address_2"
    t.text     "bill_to_attention"
    t.text     "bill_to_city"
    t.text     "bill_to_state"
    t.text     "bill_to_zip"
    t.text     "bill_to_phone"
    t.text     "notes"
    t.datetime "created_at",                                                    null: false
    t.datetime "updated_at",                                                    null: false
    t.text     "email"
    t.integer  "user_id"
    t.text     "bill_to_email"
    t.boolean  "is_taxable"
    t.decimal  "sub_total",            precision: 10, scale: 2, default: 0.0
    t.decimal  "shipping_total",       precision: 10, scale: 2, default: 0.0
    t.decimal  "tax_total",            precision: 10, scale: 2, default: 0.0
    t.boolean  "credit_hold",                                   default: false
    t.decimal  "discount_total",       precision: 10, scale: 2, default: 0.0
    t.integer  "subscription_id"
    t.text     "state"
  end

  add_index "orders", ["account_id"], name: "order_customer_id_ix", using: :btree
  add_index "orders", ["id"], name: "order_id_ix", using: :btree

  create_table "payment_methods", force: :cascade do |t|
    t.text    "name"
    t.boolean "active"
  end

  create_table "payment_plan_templates", force: :cascade do |t|
    t.text  "name"
    t.float "amount"
  end

  create_table "payment_plans", force: :cascade do |t|
    t.text    "name"
    t.integer "account_id"
    t.integer "payment_plan_template_id"
    t.date    "billing_start"
    t.date    "billing_end"
    t.date    "last_billing_date"
    t.float   "amount"
  end

  create_table "payments", force: :cascade do |t|
    t.integer  "account_id"
    t.integer  "payment_method_id"
    t.integer  "credit_card_id"
    t.decimal  "amount",             precision: 10, scale: 2,                               null: false
    t.text     "stripe_charge_id"
    t.text     "payment_type",                                default: "CreditCardPayment"
    t.text     "first_name"
    t.text     "last_name"
    t.text     "last_four"
    t.text     "card_type"
    t.boolean  "success",                                     default: false
    t.boolean  "captured",                                    default: false
    t.text     "authorization_code"
    t.text     "check_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "date"
    t.decimal  "refunded",           precision: 10, scale: 2
  end

  create_table "permissions", force: :cascade do |t|
    t.text     "mdl_name",                    null: false
    t.boolean  "can_create",  default: false, null: false
    t.boolean  "can_read",    default: false, null: false
    t.boolean  "can_update",  default: false, null: false
    t.boolean  "can_destroy", default: false, null: false
    t.integer  "role_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "permissions", ["role_id"], name: "index_permissions_on_role_id", using: :btree

  create_table "prices", force: :cascade do |t|
    t.integer  "item_id"
    t.integer  "min_qty"
    t.integer  "max_qty"
    t.text     "_type",                                   default: "Default"
    t.datetime "start_date"
    t.datetime "end_date"
    t.boolean  "combinable",                              default: false
    t.integer  "appliable_id"
    t.text     "appliable_type"
    t.decimal  "price",          precision: 10, scale: 2
  end

  create_table "purchase_order_line_item_receipts", force: :cascade do |t|
    t.integer  "purchase_order_line_item_id"
    t.integer  "purchase_order_receipt_id"
    t.integer  "quantity_received"
    t.datetime "date"
    t.integer  "bin_id"
    t.integer  "item_id"
  end

  create_table "purchase_order_line_items", force: :cascade do |t|
    t.integer "purchase_order_id"
    t.integer "purchase_order_line_number"
    t.integer "item_id"
    t.float   "quantity"
    t.float   "price"
    t.float   "discount"
    t.text    "description"
    t.integer "quantity_received",          default: 0
    t.integer "order_line_item_id"
  end

  create_table "purchase_order_receipts", force: :cascade do |t|
    t.integer  "purchase_order_id"
    t.text     "number"
    t.datetime "date"
  end

  create_table "purchase_order_shipping_methods", force: :cascade do |t|
    t.integer  "purchase_order_id"
    t.integer  "shipping_method_id"
    t.float    "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchase_orders", force: :cascade do |t|
    t.text     "number"
    t.integer  "vendor_id"
    t.integer  "contact_id"
    t.datetime "date"
    t.datetime "due_date"
    t.datetime "completed_at"
    t.boolean  "canceled"
    t.boolean  "locked"
    t.boolean  "drop_ship_order"
    t.text     "ship_to_account_name"
    t.text     "ship_to_address_1"
    t.text     "ship_to_address_2"
    t.text     "ship_to_attention"
    t.text     "ship_to_city"
    t.text     "ship_to_state"
    t.text     "ship_to_zip"
    t.text     "ship_to_phone"
    t.text     "ship_from_vendor_name"
    t.text     "ship_from_address_1"
    t.text     "ship_from_address_2"
    t.text     "ship_from_attention"
    t.text     "ship_from_city"
    t.text     "ship_from_state"
    t.text     "ship_from_zip"
    t.text     "ship_from_phone"
    t.text     "notes"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "reciepts", force: :cascade do |t|
    t.integer "payment_plan_id"
    t.date    "from_date"
    t.text    "to_date"
    t.float   "amount"
  end

  create_table "return_authorizations", force: :cascade do |t|
    t.text     "number"
    t.integer  "order_id"
    t.integer  "customer_id"
    t.integer  "reviewer_id"
    t.text     "reason"
    t.text     "status"
    t.datetime "date"
    t.datetime "expiration_date"
    t.text     "notes"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.decimal  "amount"
  end

  create_table "roles", force: :cascade do |t|
    t.text     "name"
    t.integer  "resource_id"
    t.text     "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "schedules", force: :cascade do |t|
    t.text     "cron"
    t.text     "worker"
    t.text     "name"
    t.text     "arguments",   default: [],   array: true
    t.text     "description"
    t.boolean  "enabled",     default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "settings", force: :cascade do |t|
    t.text "key"
    t.text "value"
    t.text "description"
  end

  create_table "shipments", force: :cascade do |t|
    t.integer  "order_id"
    t.text     "number"
    t.datetime "date"
    t.text     "carrier"
    t.datetime "ship_date"
  end

  create_table "shipping_calculators", force: :cascade do |t|
    t.text "name"
    t.text "description"
    t.text "calculation_method"
    t.text "calculation_amount"
  end

  create_table "shipping_methods", force: :cascade do |t|
    t.integer "shipping_calculator_id"
    t.text    "name"
    t.decimal "rate",                   precision: 10, scale: 2
    t.text    "description"
    t.boolean "active"
    t.float   "minimum_amount"
    t.float   "free_at_amount"
  end

  create_table "static_pages", force: :cascade do |t|
    t.text "title"
    t.text "content"
    t.text "slug"
  end

  add_index "static_pages", ["slug"], name: "index_static_pages_on_slug", unique: true, using: :btree

  create_table "subscriptions", force: :cascade do |t|
    t.integer "address_id"
    t.integer "item_id"
    t.integer "quantity"
    t.text    "frequency"
    t.integer "bill_address_id"
    t.integer "account_id"
    t.integer "credit_card_id"
    t.text    "payment_method"
    t.text    "state"
  end

  create_table "tax_rates", force: :cascade do |t|
    t.text     "state_code"
    t.text     "region_name"
    t.text     "zip_code"
    t.float    "rate"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "state_rate"
    t.float    "county_rate"
    t.float    "city_rate"
    t.float    "special_rate"
    t.text     "region_code"
  end

  create_table "tracking_numbers", force: :cascade do |t|
    t.integer "shipment_id"
    t.integer "carrier_id"
    t.text    "number"
    t.boolean "delivered"
    t.text    "signed_by"
  end

  create_table "transactions", force: :cascade do |t|
    t.integer "payment_id"
    t.text    "transaction_type"
    t.decimal "amount",             precision: 10, scale: 2, null: false
    t.text    "authorization_code"
  end

  create_table "transfers", force: :cascade do |t|
    t.integer "from_id"
    t.integer "to_id"
    t.integer "quantity"
  end

  create_table "user_accounts", force: :cascade do |t|
    t.integer "user_id"
    t.integer "account_id"
  end

  create_table "users", force: :cascade do |t|
    t.text     "email",                             default: "", null: false
    t.text     "encrypted_password",                default: "", null: false
    t.text     "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                     default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.text     "current_sign_in_ip"
    t.text     "last_sign_in_ip"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.text     "first_name"
    t.text     "last_name"
    t.text     "phone_number"
    t.integer  "group_id"
    t.integer  "account_id"
    t.string   "authentication_token",   limit: 30
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

  create_table "vendors", force: :cascade do |t|
    t.text     "number"
    t.integer  "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "warehouses", force: :cascade do |t|
    t.text "name"
    t.text "_type"
  end

end
