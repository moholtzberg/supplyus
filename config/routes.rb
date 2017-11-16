require 'sidekiq/web'
require 'sidekiq-scheduler/web'
Rails.application.routes.draw do
  authenticate :user, lambda { |u| u.has_role?(:super_admin) } do
    mount Sidekiq::Web => '/sidekiq'
  end
  authenticate :user do
    scope "/admin" do
      resource :home, :controller => :home do 
        member do
          get :authenticate
          get :oauth_callback
        end
      end
      resources :account_payment_services
      resources :accounts do
        member do
          get :statements
          get :statements_all
        end
        resources :contacts
        resources :charges
        resources :credit_cards
        resources :equipment do
          resources :meters, :shallow => true do
            resources :meter_readings, :shallow => true
          end
        end
        resources :invoices, :shallow => true do
          # resources :payments, :shallow => true
        end
        resources :payment_plan_templates do
          resources :payment_plans
        end
        resources :payment_plans do
          resources :invoices
        end
      end
      resources :addresses
      resources :assets do
        collection do
          post :delete, action: :destroy, as: 'delete'
          post :change_position, action: :update, as: 'change_position'
        end
      end
      resources :bins
      resources :brands
      resources :brand_imports
      resources :categories do
        collection do
          get :autocomplete
          post :datatables
          post :change_position, action: :update, as: 'change_position'
        end
      end
      resources :charges
      resources :contacts
      resources :credit_cards
      resources :customers do
        collection do
          get :autocomplete
          post :datatables
        end
      end
      resources :discount_codes
      resources :discount_code_effects, only: [:edit, :update]
      resources :discount_code_rules, only: [:new, :create, :destroy]
      resources :email_deliveries do
        collection do
          post :datatables
        end
      end
      resources :equipment
      resources :equipment_imports
      resources :equipment_alerts
      resources :groups do 
        member do 
          get :equipment_by_customer
          get :invoices_by_customer
          get :items
          get :items_by_customer
          get :items_for_customer
          get :statements
        end
      end
      resources :group_item_prices
      resources :inventories do
        resources :transfers, only: [:new, :create]
      end
      resources :invoices
      resources :items do
        collection do
          get :autocomplete
          post :datatables
          get :actual_price_by_item_number_and_account_id
        end
      end
      resources :item_categories
      resources :item_imports
      resources :item_lists
      resources :item_item_lists
      resources :item_vendor_prices
      resources :item_vendor_price_imports
      resources :jobs
      resources :makes
      resources :machine_models
      resources :machine_model_items
      resources :meters
      resources :meter_readings
      resources :orders do
        collection do
          get :autocomplete
          post :datatables
          get :not_submitted
          get :locked
          get :shipped
          get :fulfilled
          get :unfulfilled
          get :canceled
          get :unpaid
          get :returnable_items
        end
        member do
          get :expand
          put :submit
          put :approve
          put :cancel
          put :lock
          put :resend_invoice
          post :resend_invoice_notification
          put :resend_order
          post :resend_order_confirmation
          put :credit_hold
          post :apply_code
        end
        resources :shipments, :only => [:new, :create]
        # resources :payments, :shallow => true
        resources :invoices
      end
      resources :order_discount_codes
      resources :order_line_items
      resources :payments do
        member do
          put :finalize
        end
      end
      resources :payment_plans
      resources :payment_plan_templates
      resources :prices
      resources :price_imports
      resources :purchase_orders do
        collection do
          post :datatables
          get :line_items_from_order
        end          
        member do
          put :lock
          put :resend_invoice
          put :resend_order
        end
        resources :purchase_order_receipts, :only => [:new, :create, :destroy]
      end
      resources :purchase_order_line_items
      resources :reports, :only => :index do
        collection do
          get :sales_tax
          get :item_usage
          get :item_usage_for_account_ids
          get :item_usage_by_group
          get :ar_aging
          get :vendor_prices
        end
      end
      resources :return_authorizations, except: [:edit, :update] do
        member do
          get :set_bins
          get :set_amount
          put :receive
          put :refund
          put :confirm
          put :cancel
        end
      end
      resources :roles do
        collection do
          post :add_role_to_user
          delete :remove_role_from_user
        end
      end
      resources :sales_reps
      resources :schedules
      resources :settings
      resources :static_pages
      resources :subscriptions do
        member do
          post :generate_order
        end
      end
      resources :tax_rates
      resources :users do
        get :edit_password
        get :reset_password
      end
      resources :vendors
      resources :warehouses
      get "items/delete/:id" => "items#delete"
      get "/" => "home#show"
      get "/check_for_import" => "item_imports#check_for_import"
    end
  end
  
  devise_for :users, :controllers => { 
        sessions: "users/sessions",
        passwords: "users/passwords",
        registrations: "users/registrations"
  }

  namespace :my_account do
    resources :addresses, only: [:index, :new, :create, :destroy]
    resources :credit_cards
    resources :item_item_lists, only: [:create, :destroy]
    resources :item_lists
    resources :subscriptions do
      member do
        get :details
        patch :details, action: :update_details
      end
    end
    resources :orders, param: :order_number, only: [:index, :show, :return]
    resources :return_authorizations, only: [:new, :create]
  end

  get   "checkout/address" => "checkout#address"
  patch "checkout/address" => "checkout#update_address"
  get   "checkout/shipping" => "checkout#shipping"
  patch "checkout/shipping" => "checkout#update_shipping"
  get   "checkout/payment" => "checkout#payment"
  patch "checkout/payment" => "checkout#update_payment"
  get   "checkout/confirm" => "checkout#confirm"
  patch "checkout/submit"=> "checkout#submit"
  post  "checkout/apply_code" => "checkout#apply_code"
  delete  "checkout/remove_code" => "checkout#remove_code"

  post  "/add_to_cart" => "shop#add_to_cart"
  patch "/add_to_cart" => "shop#add_to_cart"
  post  "/update_cart" => "shop#update_cart"
  patch "/update_cart" => "shop#update_cart"
  
  get "/my_account/items" => "shop#my_items"
  post "/my_account/invoice/:invoice_number/pay" => "shop#pay_invoice"
  get "/my_account/invoice/:invoice_number" => "shop#view_invoice"
  get "/my_account/:account_id" => "shop#view_account"
  get "/my_account" => "shop#my_account"
  get "/edit_account" => "shop#edit_account"

  get "/cart" => "shop#cart"
  get "/search" => "shop#search"
  get "/search_autocomplete" => "shop#search_autocomplete"
  
  get "/pages/:static_page" => "shop#page"
  get "/categories/:parent_id" => "shop#categories"
  get "/:category/:item" => "shop#item"
  get "/:category" => "shop#category"
  get "/" => "shop#index"
  
  namespace :api, defaults: {format: :json} do
    scope :v1 do
      resources :equipment_alerts, only: [:index, :show, :create, :update]
      resources :email_deliveries do
        collection do
          post :webhook
        end
      end
    end
  end

end