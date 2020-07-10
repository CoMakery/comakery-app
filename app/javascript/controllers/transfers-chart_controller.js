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

    let color = d3.scaleOrdinal()
      .domain(data.map(d => d.name))
      .range(d3.quantize(t => d3.interpolateViridis(t * 0.8 + 0.1), data.length).reverse())
      .unknown('#ccc')

    color = d3.scaleOrdinal().range(window.chartColors)

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
        .attr('fill', d => color(d.data.name))
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

    let color = d3.scaleOrdinal()
      .domain(series.map(d => d.key))
      .range(d3.quantize(t => d3.interpolateViridis(t * 0.8 + 0.1), series.length).reverse())
      .unknown('#ccc')

    color = d3.scaleOrdinal().range(window.chartColors)

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
      .attr('fill', d => color(d.key))
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

    this.drawStackedChartLegend({color})
  }

  // Extracted from: https://observablehq.com/@d3/color-legend
  drawStackedChartLegend({
    color,
    title,
    tickSize = 6,
    width = 300,
    height = 44 + tickSize,
    marginTop = 18,
    marginRight = 0,
    marginBottom = 16 + tickSize,
    marginLeft = 0,
    ticks = width / 64,
    tickFormat,
    tickValues
  } = {}) {
    const svg = d3.select('svg#stacked-chart-legend')
      .attr('width', width)
      .attr('height', height)
      .attr('viewBox', [0, 0, width, height])
      .style('overflow', 'visible')
      .style('display', 'block')

    let tickAdjust = g => g.selectAll('.tick line').attr('y1', marginTop + marginBottom - height)
    let x

    if (color.interpolate) {
      const n = Math.min(color.domain().length, color.range().length)

      x = color.copy().rangeRound(d3.quantize(d3.interpolate(marginLeft, width - marginRight), n))

      svg.append('image')
          .attr('x', marginLeft)
          .attr('y', marginTop)
          .attr('width', width - marginLeft - marginRight)
          .attr('height', height - marginTop - marginBottom)
          .attr('preserveAspectRatio', 'none')
          .attr('xlink:href', this._ramp(color.copy().domain(d3.quantize(d3.interpolate(0, 1), n))).toDataURL())
    } else if (color.interpolator) {
      x = Object.assign(color.copy()
          .interpolator(d3.interpolateRound(marginLeft, width - marginRight)),
          {range() { return [marginLeft, width - marginRight] }})

      svg.append('image')
          .attr('x', marginLeft)
          .attr('y', marginTop)
          .attr('width', width - marginLeft - marginRight)
          .attr('height', height - marginTop - marginBottom)
          .attr('preserveAspectRatio', 'none')
          .attr('xlink:href', this._ramp(color.interpolator()).toDataURL())

      if (!x.ticks) {
        if (tickValues === undefined) {
          const n = Math.round(ticks + 1)
          tickValues = d3.range(n).map(i => d3.quantile(color.domain(), i / (n - 1)))
        }
        if (typeof tickFormat !== 'function') {
          tickFormat = d3.format(tickFormat === undefined ? ',f' : tickFormat)
        }
      }
    } else if (color.invertExtent) {
      const thresholds
          = color.thresholds ? color.thresholds() // scaleQuantize
          : color.quantiles ? color.quantiles() // scaleQuantile
          : color.domain() // scaleThreshold

      const thresholdFormat
          = tickFormat === undefined ? d => d
          : typeof tickFormat === 'string' ? d3.format(tickFormat)
          : tickFormat

      x = d3.scaleLinear()
          .domain([-1, color.range().length - 1])
          .rangeRound([marginLeft, width - marginRight])

      svg.append('g')
        .selectAll('rect')
        .data(color.range())
        .join('rect')
          .attr('x', (d, i) => x(i - 1))
          .attr('y', marginTop)
          .attr('width', (d, i) => x(i) - x(i - 1))
          .attr('height', height - marginTop - marginBottom)
          .attr('fill', d => d)

      tickValues = d3.range(thresholds.length)
      tickFormat = i => thresholdFormat(thresholds[i], i)
    } else {
      x = d3.scaleBand()
          .domain(color.domain())
          .rangeRound([marginLeft, width - marginRight])

      svg.append('g')
        .selectAll('rect')
        .data(color.domain())
        .join('rect')
          .attr('x', x)
          .attr('y', marginTop)
          .attr('width', Math.max(0, x.bandwidth() - 1))
          .attr('height', height - marginTop - marginBottom)
          .attr('fill', color)

      tickAdjust = () => {}
    }

    svg.append('g')
      .attr('transform', `translate(0,${height - marginBottom})`)
      .call(d3.axisBottom(x)
        .ticks(ticks, typeof tickFormat === 'string' ? tickFormat : undefined)
        .tickFormat(typeof tickFormat === 'function' ? tickFormat : undefined)
        .tickSize(tickSize)
        .tickValues(tickValues))
      .call(tickAdjust)
      .call(g => g.select('.domain').remove())
      .call(g => g.append('text')
        .attr('x', marginLeft)
        .attr('y', marginTop + marginBottom - height - 6)
        .attr('fill', 'currentColor')
        .attr('text-anchor', 'start')
        .attr('font-weight', 'bold')
        .text(title))
  }

  // Extracted from: https://observablehq.com/@d3/color-legend
  _ramp(color, n = 256) {
    const canvas = DOM.canvas(n, 1)
    const context = canvas.getContext('2d')
    for (let i = 0; i < n; ++i) {
      context.fillStyle = color(i / (n - 1))
      context.fillRect(i, 0, 1, 1)
    }
    return canvas
  }

  // Extracted from: https://observablehq.com/@d3/color-legend
  _entity(character) {
    return `&#${character.charCodeAt(0).toString()};`
  }
}
