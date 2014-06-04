describe 'Category', ()->

  category = category2 = ind1 = ind2 = ind3 = ind4 = ind5 = ind6 = tangle = indices = null

  beforeEach () ->
    category  = new Category( 'cat', 80, 'osc' )
    category2 = new Category( 'cat2', 20, 'osc' )
    ind4 = new Indicator( 'ind10', 34, category2 )
    ind1 = new Indicator( 'ind1', 50, category)
    ind2 = new Indicator( 'ind2', 25, category)
    ind3 = new Indicator( 'ind3', 25, category)
    ind5 = new Indicator( 'ind11', 33, category2 )
    ind6 = new Indicator( 'ind12', 33, category2 )
    tangle = {
      setValue: (variable, value)->
    }
    Index.set_tangle( tangle )
    Index.set_indices( [ind1, ind2, ind3, ind4, ind5, ind6] )
    Index.set_categories( [category, category2] )

  describe 'get_my_indices', ()->

    it 'has set the indices', ()->
      expect( Index._indices.length).toEqual(6)

    it 'returns a list of all indicators belonging to this category', ()->
      expect( category.get_my_indices() ).toEqual( [ind1, ind2, ind3] )

  describe 'weight_sum', ()->

    it 'sums the weights of the indicators belonging to this category', ()->
      expect( category.weight_sum() ).toEqual( 100 )


  describe 'weight_sum_is_100', ()->

    it 'returns true if the sum of all category weights is 100', ()->
      expect( category.weight_sum_is_100()).toBeTruthy()

    it 'returns false if the sum of all category weights is not 100', ()->
      category2.weight = 22
      expect( category.weight_sum_is_100()).toBeFalsy()

  describe 'update', ()->

    beforeEach () ->
      spyOn( ind1, 'calculate_osc_weight')
      spyOn( ind2, 'calculate_osc_weight')
      spyOn( ind3, 'calculate_osc_weight')

      category.update(70)

    it 'sets the weight', ()->
      expect( category.weight).toEqual( 70 )

    it 'updates the osc-weights of its indicators', ()->
      for ind in [ ind1, ind2, ind3 ]
        expect( ind.calculate_osc_weight).toHaveBeenCalled()

    #it 'marks all categories if the sum of their weights is not 100', ()->