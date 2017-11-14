class SchedulesController < ApplicationController
  layout 'admin'
  helper_method :sort_column, :sort_direction
  before_action :set_schedule, only: %i[show edit update destroy]
  before_action :set_worker_list, only: %i[new create edit update]
  load_and_authorize_resource

  def index
    update_index
    respond_to do |format|
      format.html
      format.js
      format.json { render json: @schedules.to_json }
    end
  end

  def new
    @schedule = Schedule.new
  end

  def create
    @schedule = Schedule.new(schedule_params)
    @schedule.save
    update_index
  end

  def show; end

  def edit; end

  def update
    @schedule.update_attributes(schedule_params)
    update_index
  end

  def destroy
    @schedule.destroy
    update_index
  end

  private

  def set_schedule
    @schedule = Schedule.find(params[:id])
  end

  def set_worker_list
    path = File.join(Rails.root, 'app', 'workers', '*')
    @workers_with_params = Dir.glob(path).collect do |file_path|
      File.basename(file_path, '.rb').camelize.constantize
    end
    @workers_with_params = @workers_with_params.map do |w|
      [w, w.instance_method(:perform).parameters.map { |p| p[1].to_s }]
    end.to_h
  end

  def update_index
    @schedules = Schedule.order(sort_column + ' ' + sort_direction)
    @schedules = @schedules.lookup(params[:term]) if params[:term].present?
    @schedules = @schedules.paginate(page: params[:page], per_page: 25)
  end

  def schedule_params
    params.require(:schedule).permit(
      :cron, :worker, :name, :enabled, :description, arguments: []
    )
  end

  def sort_column
    default = 'schedules.created_at'
    columns = Schedule.column_names.map { |cn| "schedules.#{cn}" }
    columns.include?(params[:sort]) ? params[:sort] : default
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end
end
