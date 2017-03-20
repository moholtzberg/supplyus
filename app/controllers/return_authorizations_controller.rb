class ReturnAuthorizationsController < ApplicationController
  layout "admin"
  respond_to :json, :html, :js
  
  def index
    @return_authorizations = ReturnAuthorization.all
  end
  
  def new
    @return_authorization = ReturnAuthorization.new
    @orders = Order.is_complete.shipped
  end
  
end