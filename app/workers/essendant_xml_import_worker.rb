class EssendantXmlImportWorker
  
  include Sidekiq::Worker
  
  def perform(id)
    item = Item.find_by(id: id)
    item.update_columns(:updated_at => Time.now)
    start = Time.now
  
    puts "START >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> #{id}"
  
    current_item_id = id
  
    path = File.expand_path("#{SHARED_DIR}/ecdb.individual_items")
  
    begin
      noko = File.open("/#{path}/#{item.number}.xml") { |f| Nokogiri::XML(f) }
    rescue
    
      unless item.number.ends_with? "COMP"
        item.update_attributes(:active => false)
      end
    
      puts "No such file #{item.number}.xml"
      return false
    else
      result = current_item_id.even?
      # self.item_properties.delete_all

      ItemProperty.delete_all(:item_id => item.id)
      puts "deleted item properties"
      unless noko.xpath("//us:GlobalItem//us:GTINItem").nil?
        ItemProperty.create(item_id: current_item_id, key: "gtin_item", value: noko.xpath("//us:GlobalItem//us:GTINItem").text, active: true, :type => "Property")
      end

      unless noko.xpath("//us:GlobalItem//us:GTINCarton").nil?
        ItemProperty.create(item_id: current_item_id, key: "gtin_carton", value: noko.xpath("//us:GlobalItem//us:GTINCarton").text, active: true, :type => "Property")
      end

      unless noko.xpath("//us:GlobalItem//us:GTINBox").nil?
        ItemProperty.create(item_id: current_item_id, key: "gtin_box", value: noko.xpath("//us:GlobalItem//us:GTINBox").text, active: true, :type => "Property")
      end

      unless noko.xpath("//us:GlobalItem//us:GTINPallet").nil?
        ItemProperty.create(item_id: current_item_id, key: "gtin_pallet", value: noko.xpath("//us:GlobalItem//us:GTINPallet").text, active: true, :type => "Property")
      end

      unless noko.xpath("//us:GlobalItem//us:UPCRetail").nil?
        ItemProperty.create(item_id: current_item_id, key: "upc_retail", value: noko.xpath("//us:GlobalItem//us:UPCRetail").text, active: true, :type => "Property")
      end

      unless noko.xpath("//us:GlobalItem//us:UPCCarton").nil?
        ItemProperty.create(item_id: current_item_id, key: "upc_carton", value: noko.xpath("//us:GlobalItem//us:UPCCarton").text, active: true, :type => "Property")
      end

      unless noko.css("[status=Summary_Selling_Statement]").nil?
        ItemProperty.create(item_id: current_item_id, key: "summary_selling_statement", value: noko.css("[status=Summary_Selling_Statement]").text, active: true, :type => "Feature")
      end

      unless noko.css("[status=Selling_Point_1]").nil?
        ItemProperty.create(item_id: current_item_id, key: "selling_point_1", value: noko.css("[status=Selling_Point_1]").text, active: true, :type => "Feature")
      end

      unless noko.css("[status=Selling_Point_2]").nil?
        ItemProperty.create(item_id: current_item_id, key: "selling_point_2", value: noko.css("[status=Selling_Point_2]").text, active: true, :type => "Feature")
      end

      unless noko.css("[status=Selling_Point_3]").nil?
        ItemProperty.create(item_id: current_item_id, key: "selling_point_3", value: noko.css("[status=Selling_Point_3]").text, active: true, :type => "Feature")
      end

      unless noko.css("[status=Selling_Point_4]").nil?
        ItemProperty.create(item_id: current_item_id, key: "selling_point_4", value: noko.css("[status=Selling_Point_4]").text, active: true, :type => "Feature")
      end

      unless noko.css("[status=Selling_Point_5]").nil?
        ItemProperty.create(item_id: current_item_id, key: "selling_point_5", value: noko.css("[status=Selling_Point_5]").text, active: true, :type => "Feature")
      end

      unless noko.css("[status=Selling_Point_6]").nil?
        ItemProperty.create(item_id: current_item_id, key: "selling_point_6", value: noko.css("[status=Selling_Point_6]").text, active: true, :type => "Feature")
      end

      unless noko.css("[status=Selling_Point_7]").nil?
        ItemProperty.create(item_id: current_item_id, key: "selling_point_7", value: noko.css("[status=Selling_Point_7]").text, active: true, :type => "Feature")
      end

      noko.xpath("//oa:Specification//oa:Property//oa:NameValue").each_with_index do |k,v, index|
        ItemProperty.create(:item_id => current_item_id, :key => k.attributes["name"], :value => k.text, :order => index, :active => true)
      end
      puts "matchbook starting"
      noko.xpath("//us:Matchbook").each_with_index.map do |k, index|
        ItemProperty.create(:item_id => item.id, :key => k.attributes["name"], :value => k.text, :order => index, :active => true)
        rel_make    = noko.xpath("//us:Matchbook")[index].element_children[0].element_children[0].text
        rel_family  = noko.xpath("//us:Matchbook")[index].element_children[2].text
        rel_model   = noko.xpath("//us:Matchbook")[index].element_children[3].text

        cat = Category.find_by(:slug => "inks-toners")

        make_slug = rel_make.downcase.gsub(/[^0-9A-z]/, '-').gsub(/[-]+/, '-')
        make = Category.find_or_create_by(:name => rel_make, :parent_id => cat.id, :slug => make_slug)

        family_slug = rel_family.downcase.gsub(/[^0-9A-z]/, '-').gsub(/[-]+/, '-')
        family = Category.find_or_create_by(:name => rel_family, :parent_id => make.id, :slug => family_slug)

        model_slug = rel_model.downcase.gsub(/[^0-9A-z]/, '-').gsub(/[-]+/, '-')
        imodel = Category.find_or_create_by(:name => rel_model, :parent_id => family.id, :slug => model_slug)

        ItemCategory.find_or_create_by(:item_id => current_item_id, :category_id => imodel.id)
      end
    
      # (0..(noko.xpath("//us:Matchbook").count)-1).each {|i| puts noko.xpath("//us:Matchbook//us:Device")[i] }
    
      brand = Brand.find_by(:prefix => noko.css("[agencyRole=Prefix_Number]").text.gsub(/\s+/, ""))
      brand = brand.id unless brand.nil?

      noko.css("[listName=HierarchyLevel1]").map do |cat1|
        cat1_slug = cat1.text.downcase.gsub(/[^0-9A-z]/, '-').gsub(/[-]+/, '-')
        Category.find_or_create_by(:name => cat1.text, slug: cat1_slug)
      end

      noko.css("[listName=HierarchyLevel2]").each_with_index.map do |cat2, index|
        cat1 = Category.find_by(:slug => noko.css("[listName=HierarchyLevel1]")[index].text.downcase.gsub(/[^0-9A-z]/, '-').gsub(/[-]+/, '-'))
        cat2_slug = cat2.text.downcase.gsub(/[^0-9A-z]/, '-').gsub(/[-]+/, '-')
        Category.find_or_create_by(name: cat2.text, slug: cat2_slug, parent_id: cat1.id)
      end

      noko.css("[listName=HierarchyLevel3]").each_with_index.map do |cat3, index|
        cat2 = Category.find_by(:slug => noko.css("[listName=HierarchyLevel2]")[index].text.downcase.gsub(/[^0-9A-z]/, '-').gsub(/[-]+/, '-'))
        cat3_slug = cat3.text.downcase.gsub(/[^0-9A-z]/, '-').gsub(/[-]+/, '-')
        cat3 = Category.find_or_create_by(name: cat3.text, slug: cat3_slug, parent_id: cat2.id)
        ItemCategory.find_or_create_by(:item_id => current_item_id, :category_id => cat3.id)
      end
    
      height = noko.xpath("//us:Packaging//us:Dimensions//oa:HeightMeasure").text
      width = noko.xpath("//us:Packaging//us:Dimensions//oa:WidthMeasure").text
      length = noko.xpath("//us:Packaging//us:Dimensions//oa:LengthMeasure").text
      weight = noko.xpath("//us:Packaging//us:Dimensions//us:WeightMeasure").text
    
      # list_price = noko.xpath("//us:ItemList//us:ListAmount").text
      #
      active = noko.xpath("//oa:ItemStatus//oa:Code").text
      active = (active == "Y" )? true : false

      name = noko.css("[type=Long_Item_Description]").text
      description = noko.css("[type=Item_Consolidated_Copy]").text
   
      item.update_attributes(:brand_id => brand, :slug => item.number.downcase, :height => height, :width => width, :length => length, :weight => weight, :name => name, :description => description, :active => active)
    
      Image.delete_all(:item_id => item.id)

      image_array = []
      image_array.push noko.xpath("//oa:DrawingAttachment//oa:FileName").text
      noko.xpath("//oa:Attachment//oa:FileName").text.split(";").map {|a| image_array.push a}

      if image_array.empty?
        image_array.push noko.xpath("//us:SkuGroupImage").text
      end

      image_array.each_with_index.map do |single_image, pos|

        image = single_image.tr(" ", "")

        if image
          item_images = item.images
          unless Image.find_by(item_id: id, attachment_file_name: image)
            img = Image.create(:item_id => id, :attachment_file_name => image, :position => pos)
            img.upload_from_oppictures_to_s3 unless image == "NOA.JPG"
          else
            img = Image.find_by(id: item.images.first.id).update_attributes(:item_id => current_item_id, :attachment_file_name => image, :position => pos) unless image == "NOA.JPG"
            img.upload_from_oppictures_to_s3 unless image == "NOA.JPG"
          end
        end

      end

      noa_image = Image.find_by(:item_id => current_item_id, :attachment_file_name => "NOA.JPG")

      if noa_image.present?
        noa_image.delete
      end
    
    end
    puts "FINISH TIME ELAPSED -> #{Time.now - start} <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< #{id}"
    result
  end
  
end