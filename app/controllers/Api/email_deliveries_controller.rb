module Api
  class Api::EmailDeliveriesController < ApiController
    acts_as_token_authentication_handler_for User, fallback_to_devise: false
    skip_before_filter :verify_authenticity_token, only: :webhook
    skip_before_filter :authenticate_user!, only: :webhook
    skip_before_filter :check_authorization, only: :webhook

    def webhook
      @email_delivery = EmailDelivery.find(params[:message_id])
      if @email_delivery && EmailDelivery.verify_webhook(params[:token], params[:timestamp], params[:signature])
        attribute = case params[:event]
          when 'delivered' then 'delivered_at'
          when 'dropped' then 'failed_at'
          when 'opened' then 'opened_at'
        end
        @code = @email_delivery.update_attribute(attribute.to_sym, DateTime.strptime(params[:timestamp],'%s')) ? 200 : 409
      else
        @code = 406
      end
      render json: {status: @code}, status: @code
    end
  end
end