class ItemDatatable < AjaxDatatablesRails::Base

  def_delegators :@view, :dropdown, :number_to_currency

  def view_columns
    @view_columns ||= {
      id:  { source: "Item.id", cond: :eq },
      number: { source: "Item.number" },
      name: { source: "Item.name" },
      default_price: { source: "Price.price" },
      times_sold: { source: "", searchable: false},
      dropdown: { source: "", searchable: false }
    }
  end

  def data
    records.map do |record|
      {
        id: record.id,
        number: record.number,
        name: record.name,
        default_price: number_to_currency(record.default_price&.price),
        times_sold: record.times_sold.to_i,
        dropdown: dropdown(record.class, record)
      }
    end
  end

  private

  def get_raw_records
    Item.joins('LEFT OUTER JOIN prices ON items.id = prices.item_id').where(prices: {_type: 'Default'}).distinct
  end

end