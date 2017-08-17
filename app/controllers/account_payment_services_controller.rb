class AccountPaymentServicesController < ApplicationController
  layout 'admin'
  helper_method :sort_column, :sort_direction
  before_action :set_account_payment_service, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource
  
  def index
    update_index
    respond_to do |format|
      format.html
      format.json { render json: @account_payment_services.to_json }
    end
  end
  
  def new
    @account_payment_service = AccountPaymentService.new
  end
  
  def create
    @account_payment_service = AccountPaymentService.new(account_payment_service_params)
    @account_payment_service.save
    update_index
  end
  
  def show
  end
  
  def edit
  end
    
  def update
    @account_payment_service.update_attributes(account_payment_service_params)
    update_index
  end

  def destroy
    @account_payment_service.destroy
  end
    
  private

  def set_account_payment_service
    @account_payment_service = AccountPaymentService.find(params[:id])
  end

  def update_index
    @account_payment_services = AccountPaymentService.order(sort_column + " " + sort_direction)
    unless params[:term].blank?
      @account_payment_services = @account_payment_services.lookup(params[:term]) if params[:term].present?
    end
    @account_payment_services = @account_payment_services.paginate(:page => params[:page], :per_page => 25)
  end

  def account_payment_service_params
    params.require(:account_payment_service).permit(:name, :service_id, :account_name)
  end

  def sort_column
    AccountPaymentService.column_names.include?(params[:sort]) ? params[:sort] : "account_payment_services.name"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
end