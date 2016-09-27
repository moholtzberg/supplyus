class SettingsController < ApplicationController
  layout "admin"
  helper_method :sort_column, :sort_direction
  
  def index
    authorize! :read, Setting
    @settings = Setting.all
  end
  
  def new
    authorize! :create, Setting
    @setting = Setting.new
  end
  
  def create
    authorize! :create, Setting
    @setting = Setting.new(vendor_params)
    if @setting.save
      @setting = Setting.order(sort_column + " " + sort_direction)
    end
  end
  
  def edit
    authorize! :update, Setting
    @setting = Setting.find_by(:id => params[:id])
  end
  
  def update
    authorize! :update, Setting
    @setting = Setting.find_by(:id => params[:id])
    if @setting.update_attributes(setting_params)
      flash[:notice] = "\"#{@setting.key}\" has been updated"
    else
      flash[:error] = "There were some problems with the form you submitted"
    end
    @settings = Setting.where(id: params[:id])
  end
  
  private

  def setting_params
    params.require(:setting).permit(:key, :value, :description)
  end
  
  def sort_column
    puts Setting.column_names[0]
    Setting.column_names.include?(params[:sort]) ? params[:sort] : "id"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
end