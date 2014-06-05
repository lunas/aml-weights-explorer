describe 'Index', () ->

  categ = index= tangle = null

  beforeEach () ->
    categ = new Category( 'ml/tf', 60, 'osc' )
    index  = new Indicator( 'fatf', 50, categ )
    tangle = {
      setValue: (variable, value)->
      getValue: (variable) ->
        55
    }
    Index.set_tangle( tangle )

  describe 'set_weight', () ->

    beforeEach () ->
      spyOn( tangle, 'setValue' )
      index.set_weight( 23 )

    it 'sets the weight attribute', () ->
      expect( index.weight ).toEqual ( 23 )

    it 'sets the value via the tangle', () ->
      expect( tangle.setValue ).toHaveBeenCalled()

  describe 'get_weight', () ->

    it 'returns the value via the tangle', () ->
      spyOn( tangle, 'getValue' )
      index.get_weight()
      expect( tangle.getValue ).toHaveBeenCalledWith( index.variable )

    it 'returns the correct value', () ->
      expect( index.get_weight() ).toEqual( 55 )


