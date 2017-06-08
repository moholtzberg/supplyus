class DiscountCodesController < ApplicationController
  layout "admin"
  respond_to :html, :json
  def index
    authorize! :read, DiscountCode
    @discount_codes = DiscountCode.includes(:order_discount_codes).all
    if params[:times_ordered].present?
      @discount_codes = @discount_codes.times_ordered
    end
    unless params[:term].blank?
      @discount_codes = @discount_codes.lookup(params[:term]) if params[:term].present?
    end
    @discount_codes = @discount_codes.paginate(:page => params[:page], :per_page => 25)
    
  end
  
  def new
    authorize! :create, DiscountCode
    @discount_code = DiscountCode.new
    # @brands = Brand.active
    # @categories = Category.all
  end
  
  def show
    authorize! :read, DiscountCode
    @discount_code = DiscountCode.find_by(:id => params[:id])
  end
  
  def search
    authorize! :read, DiscountCode
    @results = DiscountCode.where(nil)
    search_term = params[:keywords] if params[:keywords].present?
    search_term = params[:term] if params[:term].present?
    @results = @results.lookup(search_term).paginate(:page => params[:page], :per_page => 25)
    respond_to do |format|
      format.json {render :json => @results.map(&:number)}
    end
  end
  
  def create
    authorize! :create, DiscountCode
    @discount_code = DiscountCode.create(discount_code_params)
    @discount_codes = DiscountCode.all
    @discount_codes = @discount_codes.paginate(:page => params[:page], :per_page => 25)
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def edit
    authorize! :update, DiscountCode
    @discount_code = DiscountCode.find_by(:id => params[:id])
  end
  
  def update
    authorize! :update, DiscountCode
    @discount_code = DiscountCode.find_by(:id => params[:id])
    if @discount_code.update_attributes(discount_code_params)
      flash[:notice] = "\"#{@discount_code.code}\" has been updated"
    else
      flash[:error] = "There were some problems with the form you submitted"
    end
    @discount_codes = DiscountCode.all
    @discount_codes = @discount_codes.paginate(:page => params[:page], :per_page => 25)
    respond_to do |format|
      format.html
      format.js
      format.json do 
        respond_with_bip(@discount_code)
      end
    end
  end
  
  def destroy
    authorize! :destroy, DiscountCode
    e = DiscountCode.find_by(:id => params[:id])
    e.destroy!
    @discount_codes = DiscountCode.all
    @discount_codes = @discount_codes.paginate(:page => params[:page], :per_page => 25)
    respond_to do |format|
      format.js
    end
  end
  
  private

  def discount_code_params
    params.require(:discount_code).permit(:code, :times_of_use)
  end
  
end