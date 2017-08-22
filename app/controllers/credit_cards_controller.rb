class CreditCardsController < ApplicationController
  layout 'admin'
  helper_method :sort_column, :sort_direction
  before_action :set_credit_card, only: [:edit, :update, :destroy]
  load_and_authorize_resource
  
  def index
    update_index
  end
  
  def new
    @credit_card = CreditCard.new
    @account_id = params[:account_id]
  end
  
  def create
    @account = Account.find_by(name: params[:account_name])
    @credit_card = CreditCard.new(credit_card_params.merge(account_payment_service_id: @account&.main_service&.id))
    @credit_card.store
    @credit_card.save if @credit_card.errors.empty?
    update_index
  end

  def edit
  end

  def update
    @credit_card.update_attributes(cardholder_name: credit_card_params[:cardholder_name], expiration: "#{credit_card_params[:expiration_month]}/#{credit_card_params[:expiration_year]}")
    update_index
  end

  def destroy
    @credit_card.destroy
    update_index
  end
  
  private

  def set_credit_card
    @credit_card = CreditCard.find(params[:id])
  end

  def update_index
    @credit_cards = CreditCard.includes(account_payment_service: :account).order(sort_column + " " + sort_direction)
    unless params[:term].blank?
      @credit_cards = @credit_cards.lookup(params[:term]) if params[:term].present?
    end
    @credit_cards = @credit_cards.paginate(:page => params[:page], :per_page => 25)
  end
  
  def credit_card_params
    params.require(:credit_card).permit(:cardholder_name, :credit_card_number, :expiration_month, :expiration_year, :card_security_code)
  end
  
  def sort_column
    related_columns = Account.column_names.map {|a| "accounts.#{a}" }
    columns = CreditCard.column_names.map {|a| "credit_cards.#{a}" }
    columns.push(related_columns).flatten!.uniq!
    columns.include?(params[:sort]) ? params[:sort] : "credit_cards.id"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
end