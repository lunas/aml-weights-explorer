describe "Indicator", () ->

  categ = categ2 = index = index2 = index3 = tangle = null

  beforeEach () ->
    categ  = new Category( 'ml_tf', 60, 'osc' )
    categ2 = new Category( 'legalrisk', 40, 'osc' )
    index  = new Indicator( 'index', 50, categ)
    index2 = new Indicator( 'us_inscr', 50, categ )
    index3 = new Indicator( 'freedomhouse', 100, categ2 )

    tangle = {
      setValue: (variable, value) ->
      getValue: (variable) -> false
    }
    Index.set_tangle( tangle )
    Index.set_indices( [index, index2, index3] )

  describe 'constructor', ()->

    it 'should have category "categ"', () ->
      expect( index.cat).toEqual( categ )

  describe 'update_osc_weight', ()->

    it 'should set the correct tangle variable with the calculated weight', ()->
      exp_result = index.initial_weight * categ.initial_weight / 100
      spyOn( tangle, 'setValue' )

      index.update_osc_weight()
      expect( tangle.setValue ).toHaveBeenCalledWith( 'index_osc', exp_result )

  describe 'weight_sum_is_100', ()->

    it 'returns true if the sum of weights within the same category is 100', ()->
      spyOn( index.cat, 'weight_sum' ).and.returnValue( 99.1 )

      expect( index.weight_sum_is_100() ).toBeTruthy()

    it 'returns false if the sum of weights within the same category is not 100', ()->
      spyOn( index.cat, 'weight_sum' ).and.returnValue( 102 )

      expect( index.weight_sum_is_100() ).toBeFalsy()

  describe 'update', ()->

    beforeEach () ->
      spyOn( index, 'update_osc_weight')
      spyOn( index, 'weight_sum_is_100').and.returnValue( true )
      index.update()

    it 'updates the osc-weight', ()->
      expect( index.update_osc_weight ).toHaveBeenCalled()


  describe 'mark_cat', () ->

    it 'marks each index of the same category, and no others', () ->
      spyOn( index, 'mark' )
      spyOn( index2, 'mark' )
      spyOn( index3, 'mark' )

      index.mark_cat(true)

      expect( index.mark  ).toHaveBeenCalled()
      expect( index2.mark ).toHaveBeenCalled()
      expect( index3.mark ).not.toHaveBeenCalled()