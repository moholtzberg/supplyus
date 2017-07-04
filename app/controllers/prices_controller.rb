class PricesController < ApplicationController
  layout "admin"
  respond_to :html, :json
  
  def new
    authorize! :create, Price
    @price = Price.new(price_params)
  end
  
  def create
    authorize! :create, Price
    @price = Price.create(price_params)
    flash[:error] = @price.errors.full_messages.join(', ') if @price.errors.any?
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def destroy
    authorize! :destroy, Price
    @price = Price.find_by(:id => params[:id])
    @price.destroy!
    respond_to do |format|
      format.js
    end
  end
  
  private

  def price_params
    params.require(:price).permit(:item_id, :price, :_type, :min_qty, :max_qty, :start_date, :end_date, :combinable, :appliable_id, :appliable_type)
  end
end