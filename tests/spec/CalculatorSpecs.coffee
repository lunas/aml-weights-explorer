describe "Calculator", () ->

  calc = category = category2 = tangle = indices = null
  ind1 = ind2 = ind3 = ind4 = ind5 = ind6 = ind7 = ind8 = ind9 = null

  beforeEach () ->
    category  = new Category( 'cat', 60, 'osc' )
    category2 = new Category( 'cat2', 30, 'osc' )
    category3 = new Category( 'cat3', 10, 'osc' )
    ind4 = new Indicator( 'ind4', 34, category2 )
    ind1 = new Indicator( 'ind1', 50, category)
    ind2 = new Indicator( 'ind2', 25, category)
    ind3 = new Indicator( 'ind3', 25, category)
    ind5 = new Indicator( 'ind5', 33, category2 )
    ind6 = new Indicator( 'ind6', 33, category2 )
    ind7 = new Indicator( 'ind7', 33, category3 )
    ind8 = new Indicator( 'ind8', 33, category3 )
    ind9 = new Indicator( 'ind9', 33, category3 )
    tangle = {
      setValue: (variable, value)->
      getValue: (variable) -> 0.5
    }
    Index.set_tangle( tangle )
    Index.set_indices( [ind1, ind2, ind3, ind4, ind5, ind6, ind7, ind8, ind9] )
    Index.set_categories( [category, category2, category3] )

    calc = new Calculator(Index._indices, Index._categories)

  describe 'constructor', () ->

    it 'has a list of indicators', () ->
      expect( calc.indices ).toEqual ( Index._indices )

    it 'has an empty data attribute', () ->
      expect( calc.data ).toEqual []

  describe 'calculate_osc_directly', () ->

    it 'calculates weighted average of a row based on the osc-weights specified for the indices', () ->
      row = {ind1: 1, ind2: 2, ind3: 3, ind4: 4, ind5: 5, ind6: 6}
      # since getValue is mocked and returns always 0.5:
      expected = 0.5 * (1 + 2 + 3 + 4 + 5 + 6) / (6 * 0.5)  # = 3.5
      expect( calc.calculate_osc_directly(row) ).toEqual( expected )

    it 'calculates weighted average taking care of missings', () ->
      row = {ind1: 1, ind2: NaN, ind3: 3, ind4: "NA", ind5: 5, ind6: 6}
      expected = 0.5 * (1 + 3 + 5 + 6) / (4 * 0.5)          #= 3.75
      expect( calc.calculate_osc_directly(row) ).toEqual( expected )

  describe 'update_country_osc', () ->

    beforeEach () ->
      data = [
        {country: 'Afghanistan', ind1: 1, ind2: 2, ind3: 3, ind4: 4, ind5: 5, ind6: 6}
        {country: 'Zimbabwe', ind1: 1, ind2: NaN, ind3: 3, ind4: "NA", ind5: 5, ind6: 6}
      ]
      calc.set_data(data)

    it 'returns a array of {country, OVERALL_SCORE} objects', () ->
      expect( calc.update_country_osc() ).toEqual([
        {country: 'Afghanistan', OVERALL_SCORE: 3.5}
        {country: 'Zimbabwe',    OVERALL_SCORE: 3.75}
      ])

  describe 'ready', () ->

    beforeEach () ->
      data = [
        {country: 'Afghanistan', ind1: 1, ind2: 2, ind3: 3, ind4: 4, ind5: 5, ind6: 6}
        {country: 'Zimbabwe', ind1: 1, ind2: NaN, ind3: 3, ind4: "NA", ind5: 5, ind6: 6}
      ]
      calc.set_data(data)

    it 'returns true if weights of the indicators belonging to a category sum up to 100', () ->
      spyOn( tangle, 'getValue').and.returnValue(33.3)
      expect( calc.ready() ).toBeTruthy()

    it 'returns false if weights of the indicators belonging to a category do not sum up to 100', () ->
      spyOn( tangle, 'getValue').and.returnValue(23)
      expect( calc.ready() ).toBeFalsy()