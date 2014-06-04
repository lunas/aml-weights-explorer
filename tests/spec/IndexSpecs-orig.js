describe("Index", function() {
  var ml_tf
  var fatf

  beforeEach(function() {
    ml_tf = new Category( 'ml/tf', 0.6, 'osc' )
    fatf  = new Indicator( 'fatf', 0.5, ml_tf);
  })

  it('should have type "indicator"', function() {
    expect( fatf.type).toEqual('indicator')
  })


})