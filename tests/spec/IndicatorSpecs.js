// Generated by CoffeeScript 1.7.1
(function() {
  describe("Indicator", function() {
    var categ, categ2, index, index2, index3, tangle;
    categ = categ2 = index = index2 = index3 = tangle = null;
    beforeEach(function() {
      categ = new Category('ml/tf', 60, 'osc');
      categ2 = new Category('legalrisk', 40, 'osc');
      index = new Indicator('index', 50, categ);
      index2 = new Indicator('us_inscr', 50, categ);
      index3 = new Indicator('freedomhouse', 100, categ2);
      tangle = {
        setValue: function(variable, value) {},
        getValue: function(variable) {
          return false;
        }
      };
      Index.set_tangle(tangle);
      return Index.set_indices([index, index2, index3]);
    });
    describe('constructor', function() {
      return it('should have category "categ"', function() {
        return expect(index.cat).toEqual(categ);
      });
    });
    describe('update_osc_weight', function() {
      return it('should set the correct tangle variable with the calculated weight', function() {
        var exp_result;
        exp_result = index.initial_weight * categ.initial_weight / 100;
        spyOn(tangle, 'setValue');
        index.update_osc_weight();
        return expect(tangle.setValue).toHaveBeenCalledWith('index_osc', exp_result);
      });
    });
    describe('weight_sum_is_100', function() {
      it('returns true if the sum of weights within the same category is 100', function() {
        spyOn(index.cat, 'weight_sum').and.returnValue(99.1);
        return expect(index.weight_sum_is_100()).toBeTruthy();
      });
      return it('returns false if the sum of weights within the same category is not 100', function() {
        spyOn(index.cat, 'weight_sum').and.returnValue(102);
        return expect(index.weight_sum_is_100()).toBeFalsy();
      });
    });
    describe('update', function() {
      beforeEach(function() {
        spyOn(index, 'update_osc_weight');
        spyOn(index, 'weight_sum_is_100').and.returnValue(true);
        return index.update();
      });
      return it('updates the osc-weight', function() {
        return expect(index.update_osc_weight).toHaveBeenCalled();
      });
    });
    return describe('mark_cat', function() {
      return it('marks each index of the same category, and no others', function() {
        spyOn(index, 'mark');
        spyOn(index2, 'mark');
        spyOn(index3, 'mark');
        index.mark_cat(true);
        expect(index.mark).toHaveBeenCalled();
        expect(index2.mark).toHaveBeenCalled();
        return expect(index3.mark).not.toHaveBeenCalled();
      });
    });
  });

}).call(this);
