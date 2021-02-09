module CacheExtension
  class WriteFailed < StandardError; end

  module_function

  def cache_write!(key, value, options = {})
    write_result = Rails.cache.write(key, value, **options) # will return nil even it fails, details: https://guides.rubyonrails.org/v6.0/caching_with_rails.html#activesupport-cache-rediscachestore

    # failed to write
    unless write_result
      message = "Can't write into cache: #{key} = #{value}\nCurrent cache details: #{Rails.cache.as_json}"
      raise WriteFailed, message
    end

    true
  end
end
