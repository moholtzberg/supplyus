class ReturnAuthorizationsController < ApplicationController
  layout 'admin'
  helper_method :sort_column, :sort_direction
  before_action :set_return_authorization, only:
    %i[show edit update destroy confirm cancel set_bins receive set_amount refund]
  load_and_authorize_resource except:
    %i[confirm cancel set_bins receive set_amount refund]

  def index
    update_index
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @return_authorizations.to_json }
    end
  end

  def new
    @return_authorization = ReturnAuthorization.new
    @orders = Order.is_submitted.shipped
  end

  def create
    @return_authorization = ReturnAuthorization.new(return_authorization_params)
    @return_authorization.save
    update_index
  end

  def show; end

  def edit; end

  def update
    @return_authorization.update_attributes(return_authorization_params)
    update_index
  end

  def destroy
    @return_authorization.destroy
    update_index
  end

  def confirm
    authorize! :update, ReturnAuthorization
    if @return_authorization.confirm
      @return_authorization.update_attribute(:reviewer_id, current_user.id)
      ReturnAuthorizationMailer.confirm(@return_authorization.id).deliver_later
    end
    update_index
    render 'index'
  end

  def cancel
    authorize! :update, ReturnAuthorization
    if @return_authorization.cancel
      @return_authorization.update_attribute(:reviewer_id, current_user.id)
      ReturnAuthorizationMailer.cancel(@return_authorization.id).deliver_later
    end
    update_index
    render 'update'
  end

  def set_bins
    authorize! :update, ReturnAuthorization
  end

  def set_amount
    authorize! :update, ReturnAuthorization
  end

  def refund
    authorize! :update, ReturnAuthorization
    @return_authorization.update_attributes(return_authorization_params)
    @return_authorization.refund
    update_index
  end

  def receive
    authorize! :update, ReturnAuthorization
    @return_authorization.update_attributes(return_authorization_params)
    @return_authorization.receive
    update_index
  end

  private

  def set_return_authorization
    @return_authorization = ReturnAuthorization.find(params[:id])
  end

  def update_index
    @return_authorizations = ReturnAuthorization
                             .includes(:order, :customer, :reviewer)
                             .order(sort_column + ' ' + sort_direction)
                             .paginate(page: params[:page], per_page: 25)
  end

  def return_authorization_params
    params.require(:return_authorization)
          .permit(:customer_id, :order_id, :reason, :amount,
                  line_item_returns_attributes: [:id, :bin_id])
  end

  def sort_column
    default = 'return_authorizations.created_at'
    columns = [Order, Customer, User, ReturnAuthorization].inject([]) do |a, c|
      a + c.column_names.map do |cn|
        "#{c.table_name}.#{cn}"
      end
    end
    columns.include?(params[:sort]) ? params[:sort] : default
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end
end
