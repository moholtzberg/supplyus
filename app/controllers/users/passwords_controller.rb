class Users::PasswordsController < Devise::PasswordsController
  
  layout "devise"
  
  before_filter :find_categories
  
  def check_authorization
    
  end
  
  def find_categories
    @categories = Category.is_parent
  end
  
  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  # def create
  #   super
  # end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  # def update
  #   super
  # end

  # protected

  # def after_resetting_password_path_for(resource)
  #   super(resource)
  # end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end
  
  # before_filter :find_categories
  #   before_filter :find_cart
  #   
  #   def find_categories
  #     @categories = Category.is_parent
  #   end
  #   
  #   def find_cart
  #     puts "WERE HERE"
  #     if session[:cart_id].blank?
  #       if current_user
  #         session[:cart_id] = Cart.open.find_or_create_by(:account_id => current_user.account.id).id
  #       else
  #         session[:cart_id] = Cart.create.id
  #       end
  #     else
  #       if Cart.find_by(:id => session[:cart_id]).blank?
  #         puts "ITS NIL"
  #         session[:cart_id] = nil
  #         session[:cart_id] = Cart.create.id
  #       end
  #     end
  #     puts "......---->> #{session[:cart_id]}"
  #     @cart = Cart.find_by(:id => session[:cart_id])
  #   end
  
end
