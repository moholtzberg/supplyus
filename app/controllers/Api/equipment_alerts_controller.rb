module Api
  class Api::EquipmentAlertsController < ApiController
    skip_before_filter :verify_authenticity_token, :only => :create
    respond_to :json
    
    def index
      @alerts = EquipmentAlert.all
      
      render :json => @alerts
    end
    
    def create
      @alert = EquipmentAlert.new
      @alert.equipment = Equipment.find_by(:serial => params["equipment_serial"])
      @alert.alert_identification = params["alert_idntification"]
      @alert.alert_type = params["alert_type"]
      @alert.supply_type = params["supply_type"]
      @alert.supply_color = params["supply_color"]
      @alert.supply_part_number = params["supply_part_number"]
      @alert.supply_level = params["supply_level"]
      @alert.equipment_serial = params["equipment_serial"]
      @alert.equipment_asset_id = params["equipment_asset_id"]
      @alert.equipmnet_make_model = params["equipmnet_make_model"]
      @alert.equipment_mac_address = params["equipment_mac_address"]
      @alert.equipment_ip_address = params["equipment_ip_address"]
      @alert.equipment_location = params["equipment_location"]
      # alert.equipment_group_name = params["equipment_group_name"].last
      @alert.save
      render :json => @alert
    end
  
    def equipment_alert_params
      params.require(:equipment_alert).permit(:account_id, :alert_identification, :alert_type, :supply_type, :supply_color, :supply_part_number, :supply_level, :equipment_serial, :equipment_asset_id, :equipmnet_make_model, :equipment_mac_address, :equipment_ip_address, :equipment_group_name, :equipment_location)
    end
    
    def check_authorization
      puts current_user
    end
    
  end
end