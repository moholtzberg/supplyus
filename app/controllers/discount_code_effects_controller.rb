class DiscountCodeEffectsController < ApplicationController
  layout "admin"
  respond_to :html, :json
  def index
    authorize! :read, DiscountCodeEffect
    @discount_code_effects = DiscountCodeEffect.all
    if params[:times_ordered].present?
      @discount_code_effects = @discount_code_effects.times_ordered
    end
    unless params[:term].blank?
      @discount_code_effects = @discount_code_effects.lookup(params[:term]) if params[:term].present?
    end
    @discount_code_effects = @discount_code_effects.paginate(:page => params[:page], :per_page => 25)
    
  end
  
  def new
    authorize! :create, DiscountCodeEffect
    @discount_code_effect = DiscountCodeEffect.new
    # @brands = Brand.active
    # @categories = Category.all
  end
  
  def show
    authorize! :read, DiscountCodeEffect
    @discount_code_effect = DiscountCodeEffect.find_by(:id => params[:id])
  end
  
  def search
    authorize! :read, DiscountCodeEffect
    @results = DiscountCodeEffect.where(nil)
    search_term = params[:keywords] if params[:keywords].present?
    search_term = params[:term] if params[:term].present?
    @results = @results.lookup(search_term).paginate(:page => params[:page], :per_page => 25)
    respond_to do |format|
      format.json {render :json => @results.map(&:number)}
    end
  end
  
  def create
    authorize! :create, DiscountCodeEffect
    @discount_code_effect = DiscountCodeEffect.create(discount_code_effect_params)
    @discount_code_effects = DiscountCodeEffect.all
    @discount_code_effects = @discount_code_effects.paginate(:page => params[:page], :per_page => 25)
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def edit
    authorize! :update, DiscountCodeEffect
    @discount_code_effect = DiscountCodeEffect.find_by(:id => params[:id])
  end
  
  def update
    authorize! :update, DiscountCodeEffect
    @discount_code_effect = DiscountCodeEffect.find_by(:id => params[:id])
    if @discount_code_effect.update_attributes(discount_code_effect_params)
      flash[:notice] = "\"#{@discount_code_effect.name}\" has been updated"
    else
      flash[:error] = "There were some problems with the form you submitted"
    end
    @discount_code_effects = DiscountCodeEffect.all
    @discount_code_effects = @discount_code_effects.paginate(:page => params[:page], :per_page => 25)
    respond_to do |format|
      format.html
      format.js
      format.json do 
        respond_with_bip(@discount_code_effect)
      end
    end
  end
  
  def destroy
    authorize! :destroy, DiscountCodeEffect
    e = DiscountCodeEffect.find_by(:id => params[:id])
    e.destroy!
    @discount_code_effects = DiscountCodeEffect.all
    @discount_code_effects = @discount_code_effects.paginate(:page => params[:page], :per_page => 25)
    respond_to do |format|
      format.js
    end
  end
  
  private

  def discount_code_effect_params
    params.require(:discount_code_effect).permit(:name, :amount, :percent, :shipping, :quantity, :item_id, :appliable_id, :appliable_type, :discount_code_id)
  end
end