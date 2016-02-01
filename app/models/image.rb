class Image < Asset
  
  belongs_to :item
  
  def path
    attachment_file_name
  end
  
end