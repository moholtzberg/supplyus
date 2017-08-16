class CategoryDatatable < AjaxDatatablesRails::Base

  def_delegator :@view, :dropdown

  def view_columns
    @view_columns ||= {
      id:  { source: "Category.id", cond: :eq },
      parent: { source: "", searchable: false },
      name: { source: "Category.name" },
      slug: { source: "Category.slug" },
      active: { source: "Category.active" },
      show_in_menu: { source: "Category.show_in_menu" },
      menu_id: { source: "Category.menu_id" },
      children: { source: "", searchable: false },
      items: { source: "", searchable: false },
      dropdown: { source: "", searchable: false }
    }
  end

  def data
    records.map do |record|
      {
        id: record.id,
        parent: record.parent&.name,
        name: record.name,
        slug: record.slug,
        active: record.active,
        show_in_menu: record.show_in_menu,
        menu_id: record.menu_id,
        children: record.children.count,
        items: record.items.count,
        dropdown: dropdown(record.class, record)
      }
    end
  end

  private

  def get_raw_records
    Category.joins('LEFT OUTER JOIN "categories" "parents_categories" ON "parents_categories"."id" = "categories"."parent_id"').distinct
  end

end