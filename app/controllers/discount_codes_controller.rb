class DiscountCodesController < ApplicationController
  layout "admin"
  helper_method :sort_column, :sort_direction
  before_action :set_discount_code, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  def index
    update_index
  end
  
  def new
    @discount_code = DiscountCode.new
  end
  
  def show
  end
  
  def create
    @discount_code = DiscountCode.create(discount_code_params)
    update_index
  end
  
  def edit
  end
  
  def update
    @discount_code.update_attributes(discount_code_params)
    update_index
  end
  
  def destroy
    @discount_code.destroy
    update_index
  end
  
  private

  def set_discount_code
    @discount_code = DiscountCode.find(params[:id])
  end

  def update_index
    @discount_codes = DiscountCode.includes(:effect).order(sort_column + " " + sort_direction)
    unless params[:term].blank?
      @discount_codes = @discount_codes.lookup(params[:term]) if params[:term].present?
    end
    @discount_codes = @discount_codes.paginate(:page => params[:page], :per_page => 25)
  end

  def discount_code_params
    params.require(:discount_code).permit(:code, :times_of_use)
  end

  def sort_column
    related_columns = DiscountCode.reflect_on_all_associations(:has_one).map {|a| a.klass.column_names.map {|col| "#{a.klass.table_name}.#{col}"}}
    columns = DiscountCode.column_names.map {|a| "discount_codes.#{a}" }
    columns.push(related_columns).flatten!.uniq!
    columns.include?(params[:sort]) ? params[:sort] : "discount_code_effects.name"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
end