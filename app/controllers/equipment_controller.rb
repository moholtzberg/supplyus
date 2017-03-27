class EquipmentController < ApplicationController
  layout "admin"
  helper_method :sort_column, :sort_direction
  
  def index
    authorize! :read, Equipment
    @equipment = Equipment.order(sort_column + " " + sort_direction).includes(:customer, :machine_model => [:make])
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

  def edit
    authorize! :edit, Equipment
    @equipment = Equipment.find(params[:id])
  end


  def update
    authorize! :update, Equipment
    @equipment = Equipment.find_by(:id => params[:id])
    @equipment.number = params[:equipment][:number]
    @equipment.serial = params[:equipment][:serial]
    @equipment.model_number = params[:equipment][:model_number]
    @equipment.location = params[:equipment][:location]
    @equipment.is_managed = (params[:equipment][:is_managed].to_i == 1 ? true : false)
    if @equipment.save
      flash[:notice] = "\"#{@equipment.number}\" has been updated"
    else
      flash[:error] = "There were some problems with the form you submitted"
    end
    @equipment = Equipment.lookup(@equipment.number)
    @equipment = @equipment.paginate(:page => params[:page], :per_page => 20)
  end
  
  def show
    authorize! :read, Equipment
    @equipment = Equipment.find(params[:id])
    line_items = EquipmentAlert.where(equipment_id: @equipment.id).map(&:order_line_item_id)
    orders = OrderLineItem.where(id: line_items).map(&:order_id)
    @orders = Order.where(id: orders)
  end
  
  def create
    authorize! :create, Equipment
    @equipment = Equipment.new
    @equipment.number = params[:equipment][:number]
    @equipment.serial = params[:equipment][:serial]
    @equipment.model_number = params[:equipment][:model_number]
    @equipment.location = params[:equipment][:location]
    @equipment.is_managed = (params[:equipment][:is_managed].to_i == 1 ? true : false)
    if @equipment.save
      flash[:notice] = "\"#{@equipment.number}\" has been saved"
    else
      flash[:error] = "There were some problems with the form you submitted"
    end
    @equipment = Equipment.lookup(@equipment.number)
    @equipment = @equipment.paginate(:page => params[:page], :per_page => 20)
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
    params.require(:equipment).permit(:number, :serial, :model_number, :is_managed, :location)
  end

  def sort_column
    related_columns = Equipment.reflect_on_all_associations(:belongs_to).map {|a| a.klass.column_names.map {|col| "#{a.klass.table_name}.#{col}"}}
    columns = Equipment.column_names.map {|a| "equipment.#{a}" }
    columns.push(related_columns).flatten!.uniq!
    columns.include?(params[:sort]) ? params[:sort] : "equipment.id"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
end