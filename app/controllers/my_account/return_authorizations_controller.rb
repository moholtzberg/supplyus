class MyAccount::ReturnAuthorizationsController < ApplicationController
  layout 'shop'
  respond_to :html, :json
  before_filter :find_categories
  skip_before_filter :check_authorization

  def new
    authorize! :create, ReturnAuthorization
    @return_authorization = ReturnAuthorization.new(order_id: params[:order_id])
  end

  def create
    authorize! :create, ReturnAuthorization
    @return_authorization = ReturnAuthorization.new(
      return_authorization_params.merge(customer_id: current_user.account_id)
    )
    return unless @return_authorization.save
    flash[:notice] = 'Return authorization request successfully created'
  end

  private

  def find_categories
    @menu = Category.is_parent.is_active.show_in_menu
  end

  def return_authorization_params
    params.require(:return_authorization).permit(:order_id, :reason, line_item_returns_attributes: [:order_line_item_id, :quantity])
  end
end