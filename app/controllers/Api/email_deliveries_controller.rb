module Api
  class Api::EmailDeliveriesController < ApiController
    acts_as_token_authentication_handler_for User, fallback_to_devise: false
    skip_before_filter :verify_authenticity_token, only: :webhook
    skip_before_filter :authenticate_user!, only: :webhook
    skip_before_filter :check_authorization, only: :webhook

    def webhook
      puts "**---------------------------------------------------------------**"
      puts "**---- #{params.inspect} ---- **"
      puts "**---------------------------------------------------------------**"
      @email_delivery = EmailDelivery.find(params[:identifier])
      if EmailDeliveryServices::VerifyWebhook.new.call(params[:token], params[:timestamp], params[:signature])
        @code = @email_delivery.update_attribute(attribute, time_sent) ? 200 : 409
      else
        @code = 406
      end
      render json: { status: @code }, status: @code
    end

    def message_headers
      JSON.parse(params['message-headers']).to_h
    end

    def time_sent
      DateTime.strptime(params[:timestamp], '%s')
    end

    def attribute
      case params[:event]
      when 'delivered' then :delivered_at
      when 'dropped' then :failed_at
      when 'opened' then :opened_at
      end
    end
  end
end
