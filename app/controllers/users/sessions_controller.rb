class Users::SessionsController < Devise::SessionsController
  
  layout "devise"
  
  before_filter :find_categories
  
  def check_authorization
    
  end
  
  def find_categories
    @categories = Category.is_parent
  end
  
# before_filter :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    puts "-----------------------> #{auth_options}"
    super
    # self.resource = warden.authenticate!(auth_options)
    # puts "-----------------------> #{self.resource}"
    # set_flash_message(:notice, :signed_in) if is_flashing_format?
    # sign_in(resource_name, resource)
    # yield resource if block_given?
    # respond_with resource, location: after_sign_in_path_for(resource)
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end
  
end
