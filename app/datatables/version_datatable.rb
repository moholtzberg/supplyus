class VersionDatatable < AjaxDatatablesRails::Base
  def_delegators :@view, :dropdown, :link_to

  def view_columns
    @view_columns ||= {
      item_type: { source: 'PaperTrail::Version.item_type', cond: :eq },
      item_id: { source: 'PaperTrail::Version.item_id', cond: :eq },
      event: { source: 'PaperTrail::Version.event' },
      whodunnit: { source: 'PaperTrail::Version.whodunnit' },
      created_at: { source: 'PaperTrail::Version.created_at' }
    }
  end

  def data
    records.map do |record|
      {
        item_type: record.item_type,
        item_id: link_to(record.item_id, record.item),
        event: record.event,
        whodunnit: record.whodunnit,
        created_at: record.created_at,
        dropdown: dropdown('Version', record)
      }
    end
  end

  private

  def get_raw_records
    PaperTrail::Version
  end
end
