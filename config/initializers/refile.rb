if !Rails.env.development? && !Rails.env.test?
  require "refile/s3"

  aws = {
      access_key_id: ENV['AWS_API_KEY'],
      secret_access_key: ENV['AWS_API_SECRET'],
      region: ENV['REFILE_S3_REGION'],
      bucket: ENV['REFILE_S3_BUCKET'],
  }
  Refile.cache = Refile::S3.new(prefix: "cache", max_size: 5.megabytes, **aws)
  Refile.store = Refile::S3.new(prefix: "store", **aws)
end
