import { Controller } from 'stimulus'
import * as d3 from 'd3'

export default class extends Controller {
  static targets = [ 'scales' ]

  get stackedChartData() {
    return JSON.parse(this.data.get(`stackedChartData${this.data.get('stackedChartScaleX') || 'Year'}`))
  }

  get donutChartData() {
    return JSON.parse(this.data.get('donutChartData'))
  }

  get colors() {
    return JSON.parse(this.data.get('colors'))
  }

  get stackedChartTooltip() {
    if (typeof this._stackedChartTooltip === 'undefined') {
      this._stackedChartTooltip = d3.select('#stacked-chart-tooltip')
        .attr('class', 'tooltip')
        .style('display', 'none')

      this._stackedChartTooltip.append('rect')
        .attr('width', 30)
        .attr('height', 20)
        .attr('fill', 'white')
        .style('opacity', 0.5)

      this._stackedChartTooltip.append('text')
        .attr('x', 15)
        .attr('dy', '1.2em')
        .style('text-anchor', 'middle')
        .attr('font-size', '12px')
        .attr('font-weight', 'bold')
    }

    return this._stackedChartTooltip
  }

  connect() {
    this.drawDonutChart()
    this.drawStackedChart()
  }

  setStackedChartScaleX(e) {
    this.data.set('stackedChartScaleX', e.target.dataset.scaleX)

    this.scalesTargets.forEach((e) => {
      e.classList.remove('transfers-filters--filter--options__active')
    })
    e.target.classList.add('transfers-filters--filter--options__active')

    this.drawStackedChart()
  }

  // Extracted from: https://observablehq.com/@d3/donut-chart
  drawDonutChart() {
    d3.select('svg#donut-chart').selectAll('*').remove()

    let width = 300
    let height = 300
    let data = this.donutChartData

    let svg = d3.select('svg#donut-chart')
      .attr('viewBox', [0, 0, width, height])
      .append('g')
      .attr('transform', 'translate(' + width / 2 + ',' + height / 2 + ')')

    let pie = d3.pie()
      .padAngle(0.005)
      .sort(null)
      .value(d => d.value)

    const radius = Math.min(width, height) / 2

    let arc = d3.arc().innerRadius(radius * 0.67).outerRadius(radius - 1)

    const arcs = pie(data)

    let tooltipFirst = svg.append('text')
      .attr('x', 0)
      .attr('y', 0)
      .attr('font-weight', '500')
      .attr('fill', '#3a3a3a')
      .attr('text-anchor', 'middle')
      .text('Total')

    let tooltipSecond = svg.append('text')
      .attr('x', 0)
      .attr('y', 20)
      .attr('font-weight', '500')
      .attr('fill', '#3a3a3a')
      .attr('text-anchor', 'middle')
      .attr('class', 'tooltip-second')
      .text(this.data.get('total') + ' ' + this.data.get('tokenSymbol'))

    svg.selectAll('path')
      .data(arcs)
      .join('path')
        .attr('fill', function(d) {
          return this.colors[d.data.name]
        }.bind(this))
        .attr('d', arc)
        .on('mouseover', function(d) {
          tooltipFirst.text(d.data.name + ' – ' + (d.data.ratio !== 0 ? d.data.ratio * 100 : '< 1') + '%')
          tooltipSecond.text(d.data.value + ' ' + this.data.get('tokenSymbol'))
          d3.select(d3.event.target)
            .style('stroke', '#e6e8ed')
            .style('stroke-width', '3px')
        }.bind(this))
        .on('mouseout', function() {
          tooltipFirst.text('Total')
          tooltipSecond.text(this.data.get('total') + ' ' + this.data.get('tokenSymbol'))
          d3.select(d3.event.target)
            .style('stroke', 'none')
        }.bind(this))
  }

  // Extracted from: https://observablehq.com/@d3/stacked-bar-chart
  drawStackedChart() {
    d3.select('svg#stacked-chart').selectAll('*').remove()

    let width = 700
    let height = 350
    let margin = ({top: 10, right: 10, bottom: 20, left: 30})
    let data = this.stackedChartData

    let series = d3.stack()
      .keys(Object.keys(data[0]).filter(k => k !== 'timeframe' && k !== 'i'))(data)
      .map(d => {
        d.forEach(v => (v.key = d.key))
        return d
      })

    let svg = d3.select('svg#stacked-chart')
      .attr('viewBox', [0, 0, width, height])

    let yAxis = g => g
      .attr('transform', `translate(${margin.left},0)`)
      .call(d3.axisLeft(y).ticks(null, 's').tickSize(-width, 0, 0))
      .call(g => g.selectAll('.domain').remove())

    let xAxis = g => g
      .attr('transform', `translate(0,${height - margin.bottom})`)
      .call(d3.axisBottom(x).tickSizeOuter(0))
      .call(g => g.selectAll('.domain').remove())

    let y = d3.scaleLinear()
      .domain([0, d3.max(series, d => d3.max(d, d => d[1]))])
      .rangeRound([height - margin.bottom, margin.top])

    let x = d3.scaleBand()
      .domain(data.map(d => d.timeframe))
      .range([margin.left, width - margin.right])
      .padding(0.1)

    svg.append('g')
      .call(xAxis)
      .attr('class', 'x axis')

    svg.append('g')
      .call(yAxis)
      .attr('class', 'y axis')

    let tooltip = d3.select('#stacked-chart-tooltip')
    
    svg.append('g')
      .selectAll('g')
      .data(series)
      .join('g')
      .attr('fill', function(d) {
        return this.colors[d.key]
      }.bind(this))
      .selectAll('rect')
      .data(d => d)
      .join('rect')
      .attr('x', (d, i) => x(d.data.timeframe))
      .attr('y', d => y(d[1]))
      .attr('height', d => y(d[0]) - y(d[1]))
      .attr('width', x.bandwidth())
      .on('mouseover', function() {
        tooltip
          .style('opacity', 1)
      })
      .on('mousemove', function(d) {
        tooltip
          .style('left', d3.event.pageX + 'px')
          .style('top', (d3.event.pageY - 70) + 'px')
          .style('opacity', 1)
          .html(`
            <div class="stacked-chart-tooltip__timeframe">${d.data.timeframe}</div>
            <div class="stacked-chart-tooltip__type">${d.key}</div>
            <div class="stacked-chart-tooltip__amount">${d[1] - d[0]} ${this.data.get('tokenSymbol')}</div>
          `)
      }.bind(this))
      .on('mouseout', function() {
        tooltip
          .style('opacity', 0)
      })
  }
}
