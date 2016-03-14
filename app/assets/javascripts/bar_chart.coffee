window.barChart = (selector, data)->
  margin =
    top: 20
    right: 20
    bottom: 90
    left: 50
  width = 500 - (margin.left) - (margin.right)
  height = 300 - (margin.top) - (margin.bottom)

  parseDate = d3.time.format('%Y%m%d').parse

  x = d3.scale.ordinal().rangeRoundBands([0, width], .05)
  y = d3.scale.linear().range([height, 0])
  xAxis = d3.svg.axis().scale(x).orient('bottom').tickFormat(d3.time.format('%m-%d'))
  yAxis = d3.svg.axis().scale(y).orient('left').ticks(10)

  svg = d3.select(selector)
    .append('svg')
    .attr('width', width + margin.left + margin.right)
    .attr('height', height + margin.top + margin.bottom)
    .append('g')
    .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')

  data.forEach (d) ->
    d.date = parseDate(d.date)
    d.value = +d.value

  x.domain data.map((d) -> d.date)
  y.domain [0, d3.max(data, (d) -> d.value)]

  # x-axis
  svg.append('g').
    attr('class', 'x axis').
    attr('transform', 'translate(0,' + height + ')').
    call(xAxis).
    selectAll('text').
    style('text-anchor', 'end').
    attr('dx', '-.8em').
    attr('dy', '-.55em').
    attr('transform', 'rotate(-90)')

  # y-axis
  svg.
    append('g').
    attr('class', 'y axis').
    call(yAxis).
    append('text').
    attr('transform', 'rotate(-90)').
    attr('y', 6).
    attr('dy', '.71em').
    style('text-anchor', 'end').
    text 'Value'

  # bars in chart
  svg.
    selectAll('bar').
    data(data).
    enter().
    append('rect').
    style('fill', 'steelblue').
    attr('x', (d) -> x d.date).
    attr('width', x.rangeBand()).
    attr('y', (d) -> y d.value).
    attr 'height', (d) -> height - y(d.value)