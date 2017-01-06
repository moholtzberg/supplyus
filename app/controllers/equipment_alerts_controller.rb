class EquipmentAlertsController < ApplicationController
  layout "admin"
  respond_to :html, :json
  
  def index
    authorize! :read, EquipmentAlert
    @equipment_alerts = EquipmentAlert.where(alert_type: "start").order(sort_column + " " + sort_direction)
    @equipment_alerts = @equipment_alerts.paginate(:page => params[:page], :per_page => 25)
  end
  
  # def new
  #   authorize! :create, CreditCard
  #   @credit_card = CreditCard.new
  #   @account_id = params[:account_id]
  # end
  
  def create
    alert = EquipmentAlert.new
    alert.account = Equipment.find_by(:serial => params["equipment_serial"])
    alert.alert_identification = params["alert_idntification"]
    alert.alert_type = params["alert_type"]
    alert.supply_type = params["supply_type"]
    alert.supply_color = params["supply_color"]
    alert.supply_part_number = params["supply_part_number"]
    alert.supply_level = params["supply_level"]
    alert.equipment_serial = params["equipment_serial"]
    alert.equipment_asset_id = params["equipment_asset_id"]
    alert.equipmnet_make_model = params["equipmnet_make_model"]
    alert.equipment_mac_address = params["equipment_mac_address"]
    alert.equipment_ip_address = params["equipment_ip_address"]
    alert.equipment_location = params["equipment_location"]
    alert.equipment_group_name = params["equipment_group_name"].last
    alert.save
    
  end
  
  def registration_params
    params.require(:equipment_alert).permit(:account_id, :alert_identification, :alert_type, :supply_type, :supply_color, :supply_part_number, :supply_level, :equipment_serial, :equipment_asset_id, :equipmnet_make_model, :equipment_mac_address, :equipment_ip_address, :equipment_group_name, :equipment_location)
  end
  
  def sort_column
    EquipmentAlert.column_names.include?(params[:sort]) ? params[:sort] : "equipment_alerts.created_at"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
end