require 'csv'

class Comakery::CSV
  def self.generate_multiplatform
    CSV.generate(col_sep: "\t") { |csv| yield csv }.encode('utf-16le').prepend("\xFF\xFE".force_encoding('utf-16le'))
  end
end
