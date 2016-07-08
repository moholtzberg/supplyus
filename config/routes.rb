Rails.application.routes.draw do
  
  authenticate :user do
    scope "/admin" do
      resources :accounts do
        member do
          get :statements
        end
        resources :contacts
        resources :charges
        resources :credit_cards
        resources :equipment, :shallow => true do
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
      resources :orders do
        collection do
          get :incomplete
          get :locked
          get :shipped
          get :fulfilled
          get :unfulfilled
        end
        member do
          put :lock
          put :resend_invoice
          put :resend_order
        end
        resources :shipments, :only => [:new, :create]
        # resources :payments, :shallow => true
        resources :invoices
      end
      resources :order_line_items
      resources :items do
        collection do
          get :search
        end
      end
      resources :assets
      resources :customers
      resources :groups do 
        member do 
          get :statements
        end
      end
      resources :group_item_prices
      resources :item_imports
      resources :account_item_prices
      resources :account_item_price_imports
      resources :item_vendor_prices
      resources :item_categories
      resources :item_vendor_price_imports
      resources :meters
      resources :meter_readings
      resources :contacts
      resources :equipment
      resources :payment_plan_templates
      resources :payment_plans
      resources :payments
      resources :charges
      resources :invoices
      resources :brands
      resources :brand_imports
      resources :categories
      resources :credit_cards
      resources :users do
        get :edit_password
        get :reset_password
      end
      resources :vendors
      resources :settings
      resources :roles do
        collection do
          post :add_role_to_user
          delete :remove_role_from_user
        end
      end
      get "equipment/delete/:id" => "equipment#delete"
      get "items/delete/:id" => "items#delete"
      get "/" => "home#show"
      
      get "/check_for_import" => "item_imports#check_for_import"


    end
  end
  
  devise_for :users, :controllers => { 
        sessions: "users/sessions",
        passwords: "users/passwords",
        registrations: "users/registrations"}
        
  get   "checkout/address" => "checkout#address"
  patch "checkout/address" => "checkout#update_address"
  get   "checkout/shipping" => "checkout#shipping"
  patch "checkout/shipping" => "checkout#update_shipping"
  get   "checkout/payment" => "checkout#payment"
  patch "checkout/payment" => "checkout#update_payment"
  get   "checkout/confirm" => "checkout#confirm"
  patch "checkout/complete"=> "checkout#complete"
  
  post  "/add_to_cart" => "shop#add_to_cart"
  patch "/add_to_cart" => "shop#add_to_cart"
  post  "/update_cart" => "shop#update_cart"
  patch "/update_cart" => "shop#update_cart"
  
  get "/my_account/items" => "shop#my_items"
  get "/my_account/order/:order_number" => "shop#view_order"
  get "/my_account/invoice/:invoice_number/pay" => "shop#pay_invoice"
  get "/my_account/invoice/:invoice_number" => "shop#view_invoice"
  get "/my_account/:account_id" => "shop#view_account"
  get "/my_account" => "shop#my_account"
  get "/edit_account" => "shop#edit_account"
  
  get "/cart" => "shop#cart"
  get "/search" => "shop#search"
  get "/categories/:parent_id" => "shop#categories"
  get "/:category/:item" => "shop#item"
  get "/:category" => "shop#category"
  get "/" => "shop#index"

end
