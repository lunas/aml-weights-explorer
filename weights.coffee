
$ ->

  ##################### global display variables

  scatter_width   = 1000
  scatter_height  = 1000
  scatter_padding = 40

  ##################### Tangle

  # Need to create a tangle first because a reference to it is required by the Index class.
  # So we create one with just a dummy model:
  tangle = new Tangle(document.getElementById("weights-ui"), {
    initialize: () ->
    update: () ->
  })

  # Base class to handle both indicators and categories.
  # Holds the initial weights, manages updates via a static reference to the tangle.
  # Class variables hold a list of all indicators and categories.
  window.Index = class Index

    constructor: (@variable, @initial_weight, @cat) ->

    @_indices: null
    @_categories: null
    @_tangle: null

    set_weight: (value) ->
      Index._tangle.setValue( @variable, value )

    get_weight:     () -> Index._tangle.getValue( @variable ) or @initial_weight
    get_osc_weight: () -> Index._tangle.getValue( @variable + '_osc' )

    reset: () ->
      @set_weight(@initial_weight)

    update: () -> @mark_cat( not @weight_sum_is_100() )

    weight_sum_is_100: ()-> false

    mark_cat: (switch_on)->

    selector: ()-> '[data-var=' + @variable + ']'

    mark: (switch_on)->
      if switch_on
        $( @selector() ).addClass( 'not-100')
      else
        $( @selector() ).removeClass( 'not-100' )

    near_100: (value) -> Math.abs( value - 100 ) <= 1

    # class methods

    @set_indices: (indices) -> Index._indices = indices

    @set_categories: (categories) -> Index._categories = categories

    @set_tangle: (tangle) -> Index._tangle = tangle


  window.Indicator = class Indicator extends Index

    update: ()->
      @update_osc_weight()
      super

    update_osc_weight: ()->
      osc_variable = @variable + '_osc'
      Index._tangle.setValue( osc_variable, @calculate_osc_weight() )

    calculate_osc_weight: ()-> @get_weight() * @cat.get_weight() / 100

    weight_sum_is_100: ()->
      @near_100( @cat.weight_sum() )

    mark_cat: (switch_on) -> index.mark(switch_on) for index in @cat.get_my_indices()



  window.Category = class Category extends Index

    get_my_indices: ()->
      Index._indices.filter (e) =>  # use fat arrow to get the instance-this
        e.cat.variable == @variable

    weight_sum: ()->
      sub_indices = @get_my_indices()
      sub_indices.reduce( (sum, element) ->
        sum + element.get_weight()
      0)

    weight_sum_is_100: ()->
      sum = Index._categories.reduce( (sum, element) ->
        sum + element.get_weight()
      0)
      @near_100(sum)

    mark_cat: (switch_on)-> cat.mark(switch_on) for cat in Index._categories



  model = {
    categories: [
      new Category 'ML_TF', 65, 'osc'
      new Category 'CORRUPTION_RISK', 10, 'osc'
      new Category 'FIN_TRANSPAR_STD', 15, 'osc'
      new Category 'PUBLIC_TRANSPAR_ACCOUNT', 5, 'osc'
      new Category 'POLITICAL_LEGAL_RISK', 5, 'osc'
    ]
    indicators: []

    initialize: ()->

      @indicators = [
        new Indicator 'fatf', 46.15, @categories[0]
        new Indicator 'fin_secrecy', 38.46, @categories[0]
        new Indicator 'us_incsr', 15.18, @categories[0]

        new Indicator 'ti_cpi', 100, @categories[1]

        new Indicator 'wb_business_disclosure', 12.5, @categories[2]
        new Indicator 'wef_auditing_and_reporting_std', 37.5, @categories[2]
        new Indicator 'wef_security_exchange_reg', 37.5, @categories[2]
        new Indicator 'wb_fin_sector_reg', 12.5, @categories[2]

        new Indicator 'open_budget', 33.33, @categories[3]
        new Indicator 'wb_transpar_account_corruption', 33.33, @categories[3]
        new Indicator 'idea_political_disclosure', 33.33, @categories[3]

        new Indicator 'wef_instit_strength', 33.33, @categories[4]
        new Indicator 'rule_of_law', 33.33, @categories[4]
        new Indicator 'freedom_house', 33.33, @categories[4]
      ]

      Index.set_indices( @indicators )
      Index.set_categories( @categories )
      Index.set_tangle( tangle )

      # initial weights of the indicators within their category
      for ind in @indicators
        this[ ind.variable ] = ind.get_weight()
        this[ ind.variable + '_osc' ] = ind.calculate_osc_weight()

      # initial weights of the categories
        this[ cat.variable ] = cat.initial_weight for cat in @categories

    update: ()->
      ind.update() for ind in @indicators
      cat.update() for cat in @categories

  }

  tangle.setModel( model )  # now set the real model

  ##################### OSC calculation based on updated weights

  window.Calculator = class Calculater

    constructor: (@indices, @categories) -> @data = []

    update_country_osc: ()->
      for row in @data
        {country: row.country, OVERALL_SCORE: @calculate_osc( row ) }

    calculate_osc: ( row ) ->
      sum = @indices.reduce( (sum, index) ->
        value = row[ index.variable ]
        return sum if isNaN(value)
        sum.total += index.get_osc_weight() * value
        sum.weight_total += index.get_osc_weight()
        sum
      {total: 0, weight_total: 0})
      sum.total / sum.weight_total

    ready: () -> @data.length > 0

    reset: () ->
      ind.reset() for ind in @indices.concat @categories

    set_data: (d) -> @data = d
    get_indices: () -> @indices



  calculator = new Calculator(Index._indices, Index._categories)

  ##################### Buttons to update and reset

  d3.select('#update_ranking').on 'click', ()->
    if calculator.ready()
      data = calculator.update_country_osc()
      render_ranking( '#ranking_osc', data.sort( by_('OVERALL_SCORE', true) ),
        orig_aml_data.sort( by_('OVERALL_SCORE', true) ))
      render_ranking( '#ranking_country', data.sort( by_('country') ),
        orig_aml_data.sort( by_('country') ))
      render_scatterplot(data)

  d3.select('#reset').on 'click', ()->
    calculator.reset()
    $('#update_ranking').click()

  jQuery('#display').tabs()

  ##################### D3

  # global variable that keeps the original AML ranking as of June 2014
  orig_aml_data = null

  d3.csv "data/aml-public.csv", (error, data) ->
    if error
      console.log(error)
      return

    orig_aml_data = data
    calculator.set_data(data)
    render_ranking( '#ranking_osc', data.sort( by_('OVERALL_SCORE', true) ),
      orig_aml_data.sort( by_('OVERALL_SCORE', true) ))
    render_ranking( '#ranking_country', data.sort( by_('country') ),
      orig_aml_data.sort( by_('country') ))
    render_scatterplot(data)


  render_ranking = (selector, data, orig_data) ->
    list = d3.select( selector + ' table' )
    list.selectAll('tr').remove()
    header = '<tr><th>New ranking</th><th></th><th>Old ranking</th><th></th></tr>'
    list.html(header)
    list.selectAll('tr')
      .data(data)
      .order()
      .enter()
      .append('tr')
      .html (row, i)->
        s = '<td>' + row.country + '</td>'
        s += '<td>' + d3.round(row.OVERALL_SCORE, 2) + '</td>'
        s += '<td>' + orig_data[i].country + '</td>'
        s += '<td>' + d3.round(orig_data[i].OVERALL_SCORE, 2) + '</td>'


  render_scatterplot = (data) ->
    dataset = get_comparison_data(orig_aml_data, data)

    d3.select('#scatter svg').remove()
    svg = d3.select "#scatter"
      .append 'svg'
      .attr "width",  scatter_width
      .attr "height", scatter_height

    x_scale = d3.scale.linear()
    .domain [ 0, d3.max dataset, (d) -> d.osc_old ]
    .range  [ scatter_padding, scatter_width - 3 * scatter_padding ]

    y_scale = d3.scale.linear()
    .domain [ 0, d3.max dataset, (d) -> d.osc_new ]
    .range  [ scatter_height - scatter_padding, scatter_padding ]

    svg.selectAll "circle"
      .data dataset
      .enter()
      .append "circle"
      .attr 'cx', (d) -> x_scale d.osc_old
      .attr 'cy', (d) -> y_scale d.osc_new
      .attr 'r', 3

    svg.selectAll 'text'
      .data dataset
      .enter()
      .append 'text'
      .text (d) -> d.country + ' ' + d.rank_old + ',' + d.rank_new
      .attr
        'x': (d) -> x_scale d.osc_old
        'y': (d) -> y_scale d.osc_new
        'font-family': 'sans-serif'
        'font-size': '9px'
        fill: 'blue'

    x_axis = d3.svg.axis().scale(x_scale).orient("bottom")
    y_axis = d3.svg.axis().scale(y_scale).orient("left")

    svg.append('g')
    .attr('class', 'axis')
    .attr 'transform', 'translate(0,' + (scatter_height - scatter_padding ) + ')'
    .call x_axis
    svg.append('g')
    .attr('class', 'axis')
    .attr 'transform', 'translate(' + scatter_padding + ', 0)'
    .call y_axis

    # add axis labels

    svg.append 'text'
    .attr
      class: 'x label'
      'text-anchor': 'end'
      x: scatter_width - 3*scatter_padding
      y: scatter_height - 2
    .text 'Overall score based on old AML weighting'

    svg.append 'text'
    .attr
      class: 'y label'
      'text-anchor': 'end'
      y: 2
      dy: '.75em'
      dx: - scatter_padding
      transform: 'rotate(-90)'
    .text 'Overall score based on new weights'



#################### Helper

  # returns a sort comparison function
  by_ = (key, reverse = false) ->
    (a, b) ->
      ret = if reverse then -1 else 1
      return ret  if a[key] > b[key]
      return -ret if a[key] < b[key]
      return 0

  get_comparison_data = (data_old, data_new) ->

    # add rank
    data_old.sort( by_('OVERALL_SCORE', true) )
    rank = 1
    row.rank = rank++ for row in data_old

    data_new.sort( by_('OVERALL_SCORE', true) )
    rank = 1
    row.rank = rank++ for row in data_new

    # sort both by country so we're sure thing's aren't mixed up
    data_old.sort( by_('country') )
    data_new.sort( by_('country') )

    for i in [ 0..data_old.length-1 ]
      country: data_old[i].country
      osc_old: data_old[i].OVERALL_SCORE
      osc_new: data_new[i].OVERALL_SCORE
      rank_old: data_old[i].rank
      rank_new: data_new[i].rank
