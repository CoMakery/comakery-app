class Comakery::ChartColors
  def self.array
    [
      # these are nice
      '#73C30E',
      '#7B00D7',
      '#0884FF',
      '#E5004F',
      '#D5E301',
      '#F6A504',
      '#C500FF',
      '#00C3EB',
      '#F85900',

      # these are filler and are meh
      '#b00000',
      '#e4e400',
      '#baba00',
      '#878700',
      '#00b000',
      '#008700',
      '#00ffff',
      '#00b0b0',
      '#008787',
      '#b0b0ff',
      '#8484ff',
      '#4949ff',
      '#0000ff',
      '#ff00ff',
      '#b000b0'
    ]
  end

  def self.lookup(i) # rubocop:todo Naming/MethodParameterName
    i -= array.size until i + 1 <= array.size

    array[i]
  end
end
