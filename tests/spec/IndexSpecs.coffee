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

  describe 'constructor', () ->
    it 'sets the variable name', () -> expect( index.variable).toEqual( 'fatf' )
    it 'sets the initial weight', () -> expect( index.initial_weight).toEqual( 50 )
    it 'sets a reference to its super-category', () -> expect( index.cat).toEqual( categ )

  describe 'set_weight', () ->

    beforeEach () ->
      spyOn( tangle, 'setValue' )
      index.set_weight( 23 )

    it 'does not change the initial_weight attribute', () ->
      expect( index.initial_weight ).toEqual ( 50 )

    it 'sets the value via the tangle', () ->
      expect( tangle.setValue ).toHaveBeenCalledWith( 'fatf', 23 )

  describe 'get_weight', () ->

    it 'returns the value via the tangle', () ->
      spyOn( tangle, 'getValue' )
      index.get_weight()
      expect( tangle.getValue ).toHaveBeenCalledWith( index.variable )

    it 'returns the correct value', () ->
      expect( index.get_weight() ).toEqual( 55 )

  describe 'reset', () ->

    it 'resets the corresponding tangle weight to initial_weight', () ->
      spyOn( tangle, 'setValue' )
      index.reset()
      expect( tangle.setValue ).toHaveBeenCalledWith( index.variable, index.initial_weight )
