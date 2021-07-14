module HTMLProofer
  class Middleware
    def self.options
      @options ||= {
        type: :file,
        allow_missing_href: true,
        allow_hash_href: true,
        check_html: true,
        disable_external: true,
        external_only: true,
        empty_alt_ignore: true,
        url_ignore: [%r{^/}],
        validation: {
          report_eof_tags: true,
          report_mismatched_tags: true,
          report_invalid_tags: true
        }
      }
    end
  end
end