describe 'Index', () ->

  categ = index= tangle = null

  beforeEach () ->
    categ = new Category( 'ml/tf', 60, 'osc' )
    index  = new Indicator( 'fatf', 50, categ )
    tangle = {
      setValue: (variable, value)->
      getValue: (variable) -> 33
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
      expect( index.get_weight() ).toEqual( 33 )

    it 'returns the correct value even if it is 0 ', () ->
      spyOn( tangle, 'getValue').and.returnValue 0
      expect( index.get_weight() ).toEqual( 0 )

    describe 'when the Tangle variable corresponding to the index is Null', () ->

      it 'returns the initial_weight of the index', () ->
        spyOn( tangle, 'getValue').and.returnValue null
        expect( index.get_weight()).toEqual( 50 )

    describe 'when the Tangle variable corresponding to the index is undefined', () ->

      it 'returns the initial_weight of the index', () ->
        spyOn( tangle, 'getValue').and.returnValue undefined
        expect( index.get_weight()).toEqual( 50 )

  describe 'reset', () ->

    it 'resets the corresponding tangle weight to initial_weight', () ->
      spyOn( tangle, 'setValue' )
      index.reset()
      expect( tangle.setValue ).toHaveBeenCalledWith( index.variable, index.initial_weight )
