class SessionsController < Devise::SessionsController
  
  before_filter :find_categories
  before_filter :find_cart
  
  def check_authorization
    
  end
  
  def find_categories
    @categories = Category.is_parent
  end
  
  def find_cart
    puts "WERE HERE"
    if session[:cart_id].blank?
      if current_user
        session[:cart_id] = Cart.open.find_or_create_by(:account_id => current_user.account.id).id
      else
        session[:cart_id] = Cart.create.id
      end
    else
      if Cart.find_by(:id => session[:cart_id]).blank?
        puts "ITS NIL"
        session[:cart_id] = nil
        session[:cart_id] = Cart.create.id
      end
    end
    puts "......---->> #{session[:cart_id]}"
    @cart = Cart.find_by(:id => session[:cart_id])
  end
  
end