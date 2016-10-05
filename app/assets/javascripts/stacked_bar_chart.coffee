# stolen from https://bl.ocks.org/mbostock/3886208
# http://bl.ocks.org/d3noob/8952219

window.stackedBarChart = (selector, data)->
  margin =
    top: 20
    right: 20
    bottom: 70
    left: 120
  width = 500 - (margin.left) - (margin.right)
  height = 250 - (margin.top) - (margin.bottom)

  x = d3.scale.ordinal().rangeRoundBands([0, width], .1)
  y = d3.scale.linear().rangeRound([height, 0])
  color = d3.scale.ordinal().range(window.chartColors)

  dates = for percentage in [0, 0.2, 0.4, 0.6, 0.8, 1]
    i = Math.round(percentage * (data.length-1))
    date = data[i].date

  xAxis = d3.svg.axis().scale(x).orient('bottom').tickValues(dates)

  yAxis = d3.svg.axis().scale(y).orient('left').ticks(5).tickFormat(d3.format('$,.2r'))

  svg = d3.select(selector)
    .append('svg')
      .attr('width', width + margin.left + margin.right)
      .attr('height', height + margin.top + margin.bottom)
    .append('g')
      .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')

  color.domain d3.keys(data[0]).filter((key) -> key != 'date')

  # draws stacked rectangles
  data.forEach (d) ->
    y0 = 0
    d.coins = color.domain().map((date) ->
      {
        date: date
        y0: y0
        y1: y0 += +d[date]
      }
    )
    d.total = if d.coins.length > 0 then d.coins[d.coins.length - 1].y1 else 0

  x.domain(data.map((d) -> d.date))
  y.domain([0, d3.max(data, (d) -> d.total)])

  svg.append('g')
    .attr('class', 'x axis')
    .attr('transform', 'translate(0,' + height + ')')
    .call(xAxis)
    .selectAll("text")
      .attr("y", 10)
      .attr("x", -5)
      .attr("dy", ".35em")
      .attr("transform", "rotate(-45)")
      .text((d) -> moment(d).format("M/DD"))
      .style("text-anchor", "end");

  svg.append('g')
      .attr('class', 'y axis')
      .call(yAxis)
    # .append('text')
    #   .attr('transform', 'rotate(-90)')
    #   .attr('x', -60)
    #   .attr('y', -60)
    #   .attr('dy', '.71em')
    #   .style('text-anchor', 'end')
    #   .text 'Coins'

  # graph bars
  state = svg.selectAll('.state')
    .data(data)
    .enter()
    .append('g')
      .attr('class', 'g')
      .attr('transform', (d) -> 'translate(' + x(d.date) + ',0)')

  # graph bars
  state.selectAll('rect').data((d) -> d.coins)
    .enter()
    .append('rect')
    .attr('width', x.rangeBand())
    .attr('y', (d) -> y d.y1)
    .attr('height', (d) -> y(d.y0) - y(d.y1))
    .style('fill', (d) -> color d.date)

#  legend = svg.selectAll('.legend')
#    .data(color
#    .domain().slice().reverse()).enter()
#    .append('g')
#    .attr('class', 'legend')
#    .attr('transform', (d, i) -> 'translate(0,' + i * 20 + ')')
#  legend.append('rect').attr('x', width - 18).attr('width', 18).attr('height', 18).style 'fill', color
#  legend.append('text').attr('x', width - 24).attr('y', 9).attr('dy', '.35em').style('text-anchor', 'end').text((d) -> d)
