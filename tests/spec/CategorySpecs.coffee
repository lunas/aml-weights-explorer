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
    ind6 = new Indicator( 'ind12', 0, category2 )
    tangle = {
      setValue: (variable, value)->
      getValue: (variable) -> false # so get_weight will return initial_weight
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

    describe 'when one indicator has weight 0', ()->

      it 'still correctly sums the weights of the indicators belonging to this category', ()->
        expect( category2.weight_sum()).toEqual 67

  describe 'weight_sum_is_100', ()->

    it 'returns true if the sum of all category weights is 100', ()->
      expect( category.weight_sum_is_100()).toBeTruthy()

    it 'returns false if the sum of all category weights is not 100', ()->
      category2.initial_weight = 22
      expect( category.weight_sum_is_100()).toBeFalsy()

  describe 'my_indices_weights_are_100', () ->

    it 'returns true if the sum of the indices belonging to this category is 100', () ->
      expect( category.my_indices_weights_are_100() ).toBeTruthy()

    it 'returns false if the sum of the indices belonging to this category is not 100', () ->
      ind1.initial_weight = 4
      expect( category.my_indices_weights_are_100() ).toBeFalsy()


  describe 'update', ()->

    beforeEach () ->
      spyOn( ind1, 'update_osc_weight')
      spyOn( ind2, 'update_osc_weight')
      spyOn( ind3, 'update_osc_weight')

      category.update(70)

    it 'does not change its initial_weight', ()->
      expect( category.initial_weight ).toEqual( 80 )

    # category.update doesn't need to update the indicators belonging to
    # itself, since the tangle.update calls update on each indicator, which
    # looks at the new category value to calculate the correct values.
    # it 'updates the osc-weights of its indicators', ()->
    # for ind in [ ind1, ind2, ind3 ]
    #    expect( ind.update_osc_weight ).toHaveBeenCalled()

    #it 'marks all categories if the sum of their weights is not 100', ()->

  describe 'mark_cat', () ->

    it 'marks each index of the same category, and no others', () ->
      for index in Index._indices
        spyOn( index, 'mark' )
      for cat in Index._categories
        spyOn( cat, 'mark' )

      category.mark_cat(true)

      for index in Index._indices
        expect( index.mark ).not.toHaveBeenCalled()

      for cat in Index._categories
        expect( cat.mark ).toHaveBeenCalled()

  describe 'mean', () ->

    beforeEach () ->
      for index in Index._indices
        spyOn( index, 'get_weight').and.returnValue 33.33

    it "returns the mean of row weighted by sub-indices' weights", () ->
      row = {ind1: 3, ind2: 7, ind3: 8, ind4: 9, ind5: 1}
      exp = (3 * 33.3 + 7 * 33.3 + 8 * 33.3) / (99.99)
      expect( category.mean( row ) ).toBeCloseTo( exp, 1 )

    it "returns the weighted mean of the row taking care of missings", () ->
      row = {ind1: 3, ind2: "NA", ind3: 8, ind4: 9, ind5: 1}
      exp = (3 * 33.3 + 8 * 33.3) / (66.66)
      expect( category.mean( row ) ).toBeCloseTo( exp, 1 )

