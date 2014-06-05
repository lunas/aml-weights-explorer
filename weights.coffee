
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

    get_weight: () -> Index._tangle.getValue( @variable ) or @weight

    update: () -> @mark_cat() if not @weight_sum_is_100()

    weight_sum_is_100: ()-> false

    mark_cat: ()->

    selector: ()-> '[data-var=' + @variable + ']'

    mark: ()-> $( @selector() ).addClass( 'not-100')

    unmark: ()-> $( @selector() ).removeClass( 'not-100' )

    near_100: (value) -> Math.abs( value - 100 ) <= 1

    # class methods

    @set_indices: (indices) -> Index._indices = indices

    @set_categories: (categories) -> Index._categories = categories

    @set_tangle: (tangle) -> Index._tangle = tangle


  window.Indicator = class Indicator extends Index

    update: (new_value)->
      @set_weight( new_value )
      @update_osc_weight()
      super

    update_osc_weight: ()->
      osc_variable = @variable + '_osc'
      Index._tangle.setValue( osc_variable, @calculate_osc_weight() )

    calculate_osc_weight: ()-> @get_weight() * @cat.get_weight() / 100

    weight_sum_is_100: ()->
      @near_100( @cat.weight_sum() )

    mark_cat: ()-> index.mark() for index in @cat.get_my_indices



  window.Category = class Category extends Index

    update: (new_value)->
      @set_weight(new_value)
      sub_indices = @get_my_indices()
      for index in sub_indices
        index.update_osc_weight()
      super

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

    mark_cat: ()-> cat.mark() for cat in Index._categories



  model = {
    categories: [
      new Category 'ml_tf', 65, 'osc'
      new Category 'corruption_risk', 10, 'osc'
      new Category 'fin_transpar_std', 15, 'osc'
      new Category 'public_transpar_account', 5, 'osc'
      new Category 'political_legal_risk', 5, 'osc'
    ]
    indicators: []

    initialize: ()->

      @indicators = [
        new Indicator 'fatf', 46.15, @categories[0]
        new Indicator 'fin_secrecy', 38.46, @categories[0]
        new Indicator 'us_incsr', 15.18, @categories[0]

        new Indicator 'ti_cpi', 100, @categories[1]

        new Indicator 'business_disclosure', 12.5, @categories[2]
        new Indicator 'auditing_std', 37.5, @categories[2]
        new Indicator 'security_exchange', 37.5, @categories[2]
        new Indicator 'fin_sector', 12.5, @categories[2]

        new Indicator 'open_budget', 33.33, @categories[3]
        new Indicator 'transpar_account_corr', 33.33, @categories[3]
        new Indicator 'political_disclosure', 33.33, @categories[3]

        new Indicator 'instit_strength', 33.33, @categories[4]
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
      for ind in @indicators
        ind.update_osc_weight()

  }

  tangle.setModel( model )

  ##################### D3
  d3.csv "aml.csv", (error, data) ->
    if error
      console.log(error)
      return

    render_ranking(data)
    render_scatterplot(data)


  render_ranking = (aml) ->
    list = d3.select('.ranking').append('table')
    list.selectAll('tr')
      .data(aml)
      .enter()
      .append('tr')
      .html (row)->
        s = '<td>' + row.country + '</td>'
        s += '<td>' + d3.round(row["OVERALL.SCORE"], 2) + '</td>'


  render_scatterplot = (aml) ->
