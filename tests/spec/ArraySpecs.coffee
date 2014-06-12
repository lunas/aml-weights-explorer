describe "Array", () ->

  ar = cmp = sorted = null

  beforeEach () ->
    ar = [ {x: 20}, {x:9}, {x:2}, {x:23}, {x:13} ]
    cmp = (a, b) -> a.x - b.x
    sorted = ar.copy_sort( cmp )

  describe 'copy_sort', () ->

    it 'returns the sorted array', () ->
      expect( sorted.length ).toEqual( ar.length )
      for i in [0..sorted.length-2]
        expect( sorted[i].x ).toBeLessThan( sorted[i+1].x )

    it 'does not mutate the array to be sorted', () ->
      expect( ar[0].x ).toBe( 20 )