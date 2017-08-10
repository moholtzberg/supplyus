class Users::RegistrationsController < Devise::RegistrationsController
  # prepend_before_action :check_captcha, only: [:create]
   
  layout "devise"
  
  before_filter :find_categories
  
  def check_authorization
    
  end
  
  def find_categories
    @categories = Category.is_parent
  end
  
  # before_filter :configure_sign_up_params, only: [:create]
  # before_filter :configure_account_update_params, only: [:update]

  before_filter :configure_permitted_parameters, if: :devise_controller?

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
        :email, :password, :password_confirmation, :remember_me, :first_name, :last_name,
        account: [:name],
        address: [:ship_to_address_1, :ship_to_address_2, :ship_to_city, :ship_to_state, :ship_to_zip, :ship_to_phone]
      ]
    )
  end

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    a = Customer.create({
      email: params["user"]["email"], 
      name: params["account"]["name"]
      })
    a.addresses.create({
      name: params["address"]["name"],
      address_1: params["address"]["address_1"], 
      address_2: params["address"]["address_2"], 
      city: params["address"]["city"], 
      state: params["address"]["state"], 
      zip: params["address"]["zip"], 
      phone: params["address"]["phone"],
      main: true
      })
    super
    user = User.find_by(:email => params[:user][:email])
    user.update_attributes(:account_id => a.id, :first_name => params[:user][:first_name], :last_name => params[:user][:last_name])
    user.add_role :customer
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancelg
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.for(:sign_up) {|u| u.permit(:first_name, :last_name, :account_id) }
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.for(:account_update) << :attribute
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
  
  private
  
  def check_captcha
    unless verify_recaptcha
      self.resource = resource_class.new sign_up_params
      respond_with_navigational(resource) { render :new }
    end
  end
  
end
