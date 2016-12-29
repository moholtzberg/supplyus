class EquipmentController < ApplicationController
  layout "admin"
  
  def index
    authorize! :read, Equipment
    @equipment = Equipment.order(sort_column + " " + sort_direction).includes(:group)
    unless params[:term].blank?
      @equipment = @equipment.lookup(params[:term]) if params[:term].present?
    end
    @equipment = @equipment.paginate(:page => params[:page], :per_page => 20)
  end
  
  def new
    authorize! :create, Equipment
    @equipment = Equipment.new
    @account_id = params[:account_id] if params[:account_id].present?
  end
  
  def show
    authorize! :read, Equipment
    @equipment = Equipment.find(params[:id])
  end
  
  def create
    authorize! :create, Equipment
    @account = Account.find_by(:id => params[:equipment][:account_id])
    @equipment = Equipment.create(:account_id => params[:equipment][:account_id], :number => params[:equipment][:number], :serial => params[:equipment][:serial], :make => params[:equipment][:make], :model => params[:equipment][:model])
  end
  
  def delete
    authorize! :destroy, Equipment
    @equipment = Equipment.find_by(:id => params[:id])
  end
  
  def destroy
    authorize! :destroy, Equipment
    e = Equipment.find_by(:id => params[:id])
    e.destroy!
    @account = Account.find_by(:id => e.account_id)
  end
  
  private

  def account_params
    params.require(:equipment).permit(:number, :serial)
  end

  def sort_column
    Equipment.column_names.include?(params[:sort]) ? params[:sort] : "equipment.number"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
end