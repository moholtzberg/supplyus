class TrackingNumber < ActiveRecord::Base
  
  belongs_to :shipment
  validates :number, presence: true, allow_blank: false
  
  def link
    if shipment.carrier == "UPS"
      "https://wwwapps.ups.com/WebTracking/track?track=yes&trackNums=#{number}"
    elsif shipment.carrier == "FedEx"
      "https://www.fedex.com/apps/fedextrack/?tracknumbers=#{number}"
    elsif shipment.carrier == "US Postal Service"
      "https://tools.usps.com/go/TrackConfirmAction?tLabels=#{number}"
    elsif shipment.carrier == "Ensenda"
      "http://ensenda.com/contact-us/track-a-shipment/?trackingNumber=#{number}&TRACKING_SEND=GO"
    elsif shipment.carrier == "Dohrn"
      "http://www.dohrn.com/track-pro-number.html"
    elsif shipment.carrier == "Roadrunner"
      "https://www.rrts.com/Tools/Tracking/Pages/MultipleResults.aspx?PROS=#{number}"
    else
      "https://www.google.com/webhp?sourceid=chrome-instant&ion=1&espv=2&ie=UTF-8#q=#{number}"
    end
  end
  
end