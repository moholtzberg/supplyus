class Image < Asset
  include ApplicationHelper
  require 'open-uri'

  def path
    attachment_file_name
  end

  def upload_from_oppictures_to_s3
    bucket_name = '247officesuppy'
    s3 = Aws::S3::Resource.new
    bucket = s3.bucket(bucket_name)

    image = attachment_file_name
    if bucket.object("400/400/#{image}").exists?
      puts "----> SINGLE IMAGE = #{image}"
      bucket.object("400/400/#{image}").put(acl: 'public-read') unless bucket.object("400/400/#{image}").nil?
    else
      bucket.object("400/400/#{image}").upload_file(open("http://content.oppictures.com/Master_Images/Master_Variants/Variant_500/#{image}"))
      bucket.object("400/400/#{image}").put(acl: 'public-read') unless bucket.object("400/400/#{image}").nil?
    end
  end

  def set_attachment_from_oppictures
    self.attachment = URI.parse("http://content.oppictures.com/Master_Images/Master_Variants/Variant_500/#{attachment_file_name}").open
    self.save
  end
end
