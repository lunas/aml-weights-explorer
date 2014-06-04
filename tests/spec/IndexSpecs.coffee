describe "Indicator", () ->

  ml_tf = fatf = tangle = null

  beforeEach () ->
    ml_tf = new Category( 'ml/tf', 60, 'osc' )
    fatf  = new Indicator( 'fatf', 50, ml_tf)
    tangle = {
      setValue: (variable, value)->
    }
    Index.set_tangle( tangle )

  describe 'constructor', ()->

    it 'should have type "indicator"', () ->
      expect( fatf.type).toEqual('indicator')

    it 'should have category "ml_tf"', () ->
      expect( fatf.cat).toEqual( ml_tf )

  describe 'calculate_osc_weight', ()->

    it 'should set the correct tangle variable with the calculated weight', ()->
      exp_result = fatf.weight * ml_tf.weight / 100
      spyOn( tangle, 'setValue' )

      fatf.calculate_osc_weight()
      expect( tangle.setValue ).toHaveBeenCalledWith( 'fatf_osc', exp_result )

  describe 'weight_sum_is_100', ()->

    it 'returns true if the sum of weights within the same category is 100', ()->
      spyOn( fatf.cat, 'weight_sum' ).and.returnValue( 99.1 )

      expect( fatf.weight_sum_is_100() ).toBeTruthy()

    it 'returns false if the sum of weights within the same category is not 100', ()->
      spyOn( fatf.cat, 'weight_sum' ).and.returnValue( 102 )

      expect( fatf.weight_sum_is_100() ).toBeFalsy()

  describe 'update', ()->

    beforeEach () ->
      spyOn( fatf, 'calculate_osc_weight')
      spyOn( fatf, 'weight_sum_is_100').and.returnValue( true )
      fatf.update(70)

    it 'sets the weight', ()->
      expect( fatf.weight).toEqual( 70 )

    it 'updates the osc-weight', ()->
      expect( fatf.calculate_osc_weight ).toHaveBeenCalled()

