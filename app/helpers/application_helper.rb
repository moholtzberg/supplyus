module ApplicationHelper
  
  def link_to_add_fields(name, f, association, options = {})
    new_object = f.object.send(association).klass.new(options)
    id = new_object.object_id.to_i
    options.each {|o| puts "==================oo=======================#{o.inspect}"}
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      @options = options
      puts "==================oo=======================#{@options.inspect}"
      render(association.to_s + "/form", f: builder, options: @options)
    end
    link_to(name, '#', class: "add_fields", data: {id: id, fields: fields.gsub("\n", "")})
  end
  
  def make_record_number
    puts "WE MAKING A NUMBER #{self.class}"
    if number.blank?
      puts "NUMBER IS NIL"
      last_record = self.class.unscoped.last
      if last_record.nil? or last_record.number.nil?
        record_number = "10000"
      else
        record_number = last_record.number
      end
      puts "----> INITIAL #{record_number}"
      record_number = get_number_from_record_number(record_number)
      puts "----> RECORD BEFORE NEXT #{record_number}"
      record_number = record_number.next
      puts "----> RECORD NUMBER IS #{record_number}"
      if self.class.find_by(:number => record_number)
        puts "----> SELF CLASS FIND BY :NUMBER => #{record_number} #{self.class.find_by(:number => record_number).number}"
        record_number = record_number.next
      end
      self.number = "#{self.class.to_s[0..2].upcase}#{record_number.to_i}"
    end
  end
  
  def get_number_from_record_number(record_number)
    
    record_number.sub!(/[A-Za-z]+/, "")
    return record_number
  end
  
  def errors_for(object)
    render :partial => "layouts/errors_for", :locals => {:object => object}
  end
  
  def sortable(column, title = nil)
    title ||= column.titleize
    css_class = column == sort_column ? "current #{sort_direction}" : nil
    direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
    link_to title, {:sort => column, :direction => direction}.merge(term: params[:term], action: 'index'), {:class => css_class}
  end

  def range_to_currency(range)
    number_to_currency(range.begin) + ' - ' + number_to_currency(range.end)
  end

  def dropdown(class_name, item)
    render partial: "#{class_name.to_s.pluralize.underscore}/dropdown", locals: {item: item}, formats: [:html]
  end

  def expand_button(class_name, item)
    render partial: "#{class_name.to_s.pluralize.underscore}/expand_button", locals: {item: item}, formats: [:html]
  end

  def search_params
    {term: params[:term], direction: params[:direction], sort: params[:sort], page: params[:page]}
  end
  
  def us_states
    [
      ['Alabama', 'AL'],
      ['Alaska', 'AK'],
      ['Arizona', 'AZ'],
      ['Arkansas', 'AR'],
      ['California', 'CA'],
      ['Colorado', 'CO'],
      ['Connecticut', 'CT'],
      ['Delaware', 'DE'],
      ['District of Columbia', 'DC'],
      ['Florida', 'FL'],
      ['Georgia', 'GA'],
      ['Hawaii', 'HI'],
      ['Idaho', 'ID'],
      ['Illinois', 'IL'],
      ['Indiana', 'IN'],
      ['Iowa', 'IA'],
      ['Kansas', 'KS'],
      ['Kentucky', 'KY'],
      ['Louisiana', 'LA'],
      ['Maine', 'ME'],
      ['Maryland', 'MD'],
      ['Massachusetts', 'MA'],
      ['Michigan', 'MI'],
      ['Minnesota', 'MN'],
      ['Mississippi', 'MS'],
      ['Missouri', 'MO'],
      ['Montana', 'MT'],
      ['Nebraska', 'NE'],
      ['Nevada', 'NV'],
      ['New Hampshire', 'NH'],
      ['New Jersey', 'NJ'],
      ['New Mexico', 'NM'],
      ['New York', 'NY'],
      ['North Carolina', 'NC'],
      ['North Dakota', 'ND'],
      ['Ohio', 'OH'],
      ['Oklahoma', 'OK'],
      ['Oregon', 'OR'],
      ['Pennsylvania', 'PA'],
      ['Puerto Rico', 'PR'],
      ['Rhode Island', 'RI'],
      ['South Carolina', 'SC'],
      ['South Dakota', 'SD'],
      ['Tennessee', 'TN'],
      ['Texas', 'TX'],
      ['Utah', 'UT'],
      ['Vermont', 'VT'],
      ['Virginia', 'VA'],
      ['Washington', 'WA'],
      ['West Virginia', 'WV'],
      ['Wisconsin', 'WI'],
      ['Wyoming', 'WY']
    ]
  end
  
end