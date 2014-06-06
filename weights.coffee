
$ ->
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

    constructor: (@variable, @weight, @cat) ->

    @_indices: null
    @_categories: null
    @_tangle: null

    set_weight: (value) ->
      @weight = value
      Index._tangle.setValue( @variable, @weight )

    get_weight:     () -> Index._tangle.getValue( @variable ) or @weight
    get_osc_weight: () -> Index._tangle.getValue( @variable + '_osc' )

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
        this[ cat.variable ] = cat.weight for cat in @categories

    update: ()->
      ind.update() for ind in @indicators
      cat.update() for cat in @categories

  }

  tangle.setModel( model )  # now set the real model

  ##################### OSC calculation based on updated weights

  window.Calculator = class Calculater

    constructor: (@indices) -> @data = []

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

    set_data: (d) -> @data = d
    get_indices: () -> @indices



  calculator = new Calculator(Index._indices)

  ##################### Buttons to update and reset

  d3.select('#update_ranking').on 'click', ()->
    if calculator.ready()
      render_ranking( calculator.update_country_osc() )

  ##################### D3

  d3.csv "aml.csv", (error, data) ->
    if error
      console.log(error)
      return

    calculator.set_data(data)
    render_ranking(data)
    render_scatterplot()


  render_ranking = (aml) ->
    list = d3.select('.ranking')
    list.selectAll('tr').remove()
    list.selectAll('tr')
      .data(aml)
      .enter()
      .append('tr')
      .html (row)->
        s = '<td>' + row.country + '</td>'
        s += '<td>' + d3.round(row.OVERALL_SCORE, 2) + '</td>'


  render_scatterplot = () ->
