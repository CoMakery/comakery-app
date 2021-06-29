module HTMLProofer
  class Middleware
    def self.options
      @options ||= {
        type: :file,
        allow_missing_href: true, # Permitted in html5
        allow_hash_href: true,
        check_external_hash: true,
        check_html: true,
        url_ignore: [%r{^/}], # Don't try to check if local files exist
        validation: { report_eof_tags: true },
        empty_alt_ignore: true
      }
    end
  end
end