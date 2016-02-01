Rails.application.routes.draw do
  
  authenticate :user do
    scope "/admin" do
      resources :accounts do
        resources :contacts
        resources :charges
        resources :credit_cards
        resources :equipment, :shallow => true do
          resources :meters, :shallow => true do
            resources :meter_readings, :shallow => true
          end
        end
        resources :invoices, :shallow => true do
          resources :payments, :shallow => true
        end
        resources :payment_plan_templates do
          resources :payment_plans
        end
        resources :payment_plans do
          resources :invoices
        end
      end
      resources :orders
      resources :order_line_items
      resources :items
      resources :item_imports
      resources :meters
      resources :meter_readings
      resources :contacts
      resources :equipment
      resources :payment_plan_templates
      resources :payment_plans
      resources :payments
      resources :charges
      resources :invoices
      resources :credit_cards
      resources :vendors
      get "equipment/delete/:id" => "equipment#delete"
      get "/" => "home#show"
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
  get   "checkout/confirm" => "checkout#confirm"
  patch "checkout/complete"=> "checkout#complete"
  post  "/add_to_cart" => "shop#add_to_cart"
  patch "/add_to_cart" => "shop#add_to_cart"
  post  "/update_cart" => "shop#update_cart"
  patch "/update_cart" => "shop#update_cart"
  get "/my_account" => "shop#my_account"
  get "/edit_account" => "shop#edit_account"
  get "/cart" => "shop#cart"
  get "/search" => "shop#search"
  get "/:category/:item" => "shop#item"
  get "/:category" => "shop#category"
  get "/" => "shop#index"

end
