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
    puts "WE MAKING A NUMBER"
    if number.blank?
      puts "NUMBER IS NIL"
      last_record = self.class.last
      if last_record.nil? or last_record.number.nil?
        record_number = "10000"
      else
        record_number = last_record.number
      end
      record_number = get_number_from_record_number(record_number)
      puts "----> RECORD NUMBER is #{record_number}"
      self.number = "#{self.class.to_s[0..2].upcase}#{record_number.to_i + 1}"
    end
  end
  
  def get_number_from_record_number(record_number)
    record_number.sub!(/[A-Za-z]+/, "")
    return record_number
  end
  
  def errors_for(object)
    render :partial => "layouts/errors_for", :locals => {:object => object}
  end
  
end