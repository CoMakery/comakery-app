module CacheExtension
  class WriteFailed < StandardError; end

  module_function

  def cache_write!(key, value, options = {})
    write_result = Rails.cache.write(key, value, **options) # will return nil even it fails, details: https://guides.rubyonrails.org/v6.0/caching_with_rails.html#activesupport-cache-rediscachestore

    # failed to write
    raise WriteFailed, "Can't write into cache: #{key} = #{value}" unless write_result

    true
  end
end
