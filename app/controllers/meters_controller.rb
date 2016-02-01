class MetersController < ApplicationController
  layout "admin"
  
  def index
    @meters = Meter.all
    if params[:account_id]
      @meters.by_account(params[:account_id])
    end
    if  params[:equipment_id]
      @meters.by_equipment(params[:account_id])
    end
  end
  
  def new
    @meter = Meter.new
    @equipment_id = params[:equipment_id]
  end
  
  def create
    @account = Account.find_by(:id => Equipment.find_by(:id => params[:meter][:equipment_id]).id)
    @contact = Meter.create(:equipment_id => params[:meter][:equipment_id])
  end
  
end