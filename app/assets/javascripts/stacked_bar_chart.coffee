window.stackedBarChart = (selector, data)->
  margin =
    top: 20
    right: 20
    bottom: 120
    left: 70
  width = 500 - (margin.left) - (margin.right)
  height = 300 - (margin.top) - (margin.bottom)

  x = d3.scale.ordinal().rangeRoundBands([0, width], .1)
  y = d3.scale.linear().rangeRound([height, 0])
  color = d3.scale.ordinal().range([
  				"#2484c1", "#65a620", "#7b6888", "#a05d56", "#961a1a", "#d8d23a", "#e98125", "#d0743c", "#635222", "#6ada6a",
  				"#0c6197", "#7d9058", "#207f33", "#44b9b0", "#bca44a", "#e4a14b", "#a3acb2", "#8cc3e9", "#69a6f9", "#5b388f",
  				"#546e91", "#8bde95", "#d2ab58", "#273c71", "#98bf6e", "#4daa4b", "#98abc5", "#cc1010", "#31383b", "#006391",
  				"#c2643f", "#b0a474", "#a5a39c", "#a9c2bc", "#22af8c", "#7fcecf", "#987ac6", "#3d3b87", "#b77b1c", "#c9c2b6",
  				"#807ece", "#8db27c", "#be66a2", "#9ed3c6", "#00644b", "#005064", "#77979f", "#77e079", "#9c73ab", "#1f79a7"
  			])

  xAxis = d3.svg.axis().scale(x).orient('bottom').tickValues(_.filter(_.map(data, (d, i)-> d["date"]), (d, i) -> i % 5 == 0))

  yAxis = d3.svg.axis().scale(y).orient('left').ticks(5).tickFormat(d3.format('.2s'))

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
    .append('text')
      .attr('transform', 'rotate(-90)')
      .attr('x', -60)
      .attr('y', -60)
      .attr('dy', '.71em')
      .style('text-anchor', 'end')
      .text 'Coins'

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
