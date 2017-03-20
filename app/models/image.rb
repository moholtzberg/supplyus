class Image < Asset

  include ApplicationHelper
  require 'open-uri'

  belongs_to :item

  def path
    attachment_file_name
  end

  def upload_from_oppictures_to_s3

    bucket_name = '247officesuppy/400/400'
    s3 = AWS::S3.new()
    bucket = s3.buckets[bucket_name]

    image = attachment_file_name

    if bucket.objects["#{image}"].exists?

      puts "----> SINGLE IMAGE = #{image}"
      bucket.objects["#{image}"].acl = :public_read unless bucket.objects["#{image}"].nil?
    else
      bucket.objects["#{image}"].write(open("http://content.oppictures.com/Master_Images/Master_Variants/Variant_500/#{image}") {|a| a.read})
      bucket.objects["#{image}"].acl = :public_read unless bucket.objects["#{image}"].nil?
    end

  end

end