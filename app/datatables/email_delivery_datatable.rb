class EmailDeliveryDatatable < AjaxDatatablesRails::Base

  def_delegators :@view, :dropdown, :link_to

  def view_columns
    @view_columns ||= {
      id:  { source: "EmailDelivery.id", cond: :eq },
      addressable_type: { source: "EmailDelivery.addressable_type" },
      addressable_id: { source: "EmailDelivery.addressable_id", cond: :eq },
      to_email: { source: "EmailDelivery.to_email" },
      eventable_type: { source: "EmailDelivery.eventable_type" },
      eventable_id: { source: "EmailDelivery.eventable_id", cond: :eq },
      failed_at: { source: "EmailDelivery.failed_at" },
      delivered_at: { source: "EmailDelivery.delivered_at" },
      opened_at: { source: "EmailDelivery.opened_at" },
      dropdown: { source: "", searchable: false }
    }
  end

  def data
    records.map do |record|
      {
        id: record.id,
        addressable_type: record.addressable_type,
        addressable_id: link_to(record.addressable_id, record.addressable),
        to_email: record.to_email,
        eventable_type: record.eventable_type,
        eventable_id: link_to(record.eventable_id, record.eventable),
        failed_at: record.failed_at&.strftime("%m/%d/%y %I:%M %p"),
        delivered_at: record.delivered_at&.strftime("%m/%d/%y %I:%M %p"),
        opened_at: record.opened_at&.strftime("%m/%d/%y %I:%M %p"),
        dropdown: dropdown(record.class, record)
      }
    end
  end

  private

  def get_raw_records
    filter_query = options.to_a.map { |k, v| "#{k} = \'#{v}\'" }.join(' AND ')
    EmailDelivery.all.where(filter_query)
  end
end
