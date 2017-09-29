class EmailDeliveriesController < ApplicationController
  layout 'admin'
  before_action :set_email_delivery, only: [:show]
  load_and_authorize_resource except: [:datatables, :autocomplete]

  def datatables
    authorize! :read, EmailDelivery
    render json: EmailDeliveryDatatable.new(view_context)
  end

  def index
  end
  
  def show
  end
  
  private

  def set_email_delivery
    @email_delivery = EmailDelivery.find(params[:id])
  end

end