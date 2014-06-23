// Generated by CoffeeScript 1.7.1
(function() {
  describe('Category', function() {
    var category, category2, ind1, ind2, ind3, ind4, ind5, ind6, indices, tangle;
    category = category2 = ind1 = ind2 = ind3 = ind4 = ind5 = ind6 = tangle = indices = null;
    beforeEach(function() {
      category = new Category('cat', 80, 'osc');
      category2 = new Category('cat2', 20, 'osc');
      ind4 = new Indicator('ind10', 34, category2);
      ind1 = new Indicator('ind1', 50, category);
      ind2 = new Indicator('ind2', 25, category);
      ind3 = new Indicator('ind3', 25, category);
      ind5 = new Indicator('ind11', 33, category2);
      ind6 = new Indicator('ind12', 0, category2);
      tangle = {
        setValue: function(variable, value) {},
        getValue: function(variable) {
          return null;
        }
      };
      Index.set_tangle(tangle);
      Index.set_indices([ind1, ind2, ind3, ind4, ind5, ind6]);
      return Index.set_categories([category, category2]);
    });
    describe('get_my_indices', function() {
      it('has set the indices', function() {
        return expect(Index._indices.length).toEqual(6);
      });
      return it('returns a list of all indicators belonging to this category', function() {
        return expect(category.get_my_indices()).toEqual([ind1, ind2, ind3]);
      });
    });
    describe('weight_sum', function() {
      it('sums the weights of the indicators belonging to this category', function() {
        return expect(category.weight_sum()).toEqual(100);
      });
      describe('when one indicator has weight 0 and the weight sum is not 100', function() {
        return it('still correctly sums the weights of the indicators belonging to this category', function() {
          return expect(category2.weight_sum()).toEqual(67);
        });
      });
      return describe('when one indicator has weight 0 and the weight sum is 100', function() {
        beforeEach(function() {
          return ind5.initial_weight = 66;
        });
        return it('still correctly sums the weights of the indicators belonging to this category', function() {
          return expect(category2.weight_sum()).toEqual(100);
        });
      });
    });
    describe('weight_sum_is_100', function() {
      it('returns true if the sum of all category weights is 100', function() {
        return expect(category.weight_sum_is_100()).toBeTruthy();
      });
      return it('returns false if the sum of all category weights is not 100', function() {
        category2.initial_weight = 22;
        return expect(category.weight_sum_is_100()).toBeFalsy();
      });
    });
    describe('my_indices_weights_are_100', function() {
      it('returns true if the sum of the indices belonging to this category is 100', function() {
        return expect(category.my_indices_weights_are_100()).toBeTruthy();
      });
      return it('returns false if the sum of the indices belonging to this category is not 100', function() {
        ind1.initial_weight = 4;
        return expect(category.my_indices_weights_are_100()).toBeFalsy();
      });
    });
    describe('update', function() {
      beforeEach(function() {
        spyOn(ind1, 'update_osc_weight');
        spyOn(ind2, 'update_osc_weight');
        spyOn(ind3, 'update_osc_weight');
        return category.update(70);
      });
      return it('does not change its initial_weight', function() {
        return expect(category.initial_weight).toEqual(80);
      });
    });
    describe('mark_cat', function() {
      return it('marks each index of the same category, and no others', function() {
        var cat, index, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1, _ref2, _ref3, _results;
        _ref = Index._indices;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          index = _ref[_i];
          spyOn(index, 'mark');
        }
        _ref1 = Index._categories;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          cat = _ref1[_j];
          spyOn(cat, 'mark');
        }
        category.mark_cat(true);
        _ref2 = Index._indices;
        for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
          index = _ref2[_k];
          expect(index.mark).not.toHaveBeenCalled();
        }
        _ref3 = Index._categories;
        _results = [];
        for (_l = 0, _len3 = _ref3.length; _l < _len3; _l++) {
          cat = _ref3[_l];
          _results.push(expect(cat.mark).toHaveBeenCalled());
        }
        return _results;
      });
    });
    return describe('mean', function() {
      beforeEach(function() {
        var index, _i, _len, _ref, _results;
        _ref = Index._indices;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          index = _ref[_i];
          _results.push(spyOn(index, 'get_weight').and.returnValue(33.33));
        }
        return _results;
      });
      it("returns the mean of row weighted by sub-indices' weights", function() {
        var exp, row;
        row = {
          ind1: 3,
          ind2: 7,
          ind3: 8,
          ind4: 9,
          ind5: 1
        };
        exp = (3 * 33.3 + 7 * 33.3 + 8 * 33.3) / 99.99;
        return expect(category.mean(row)).toBeCloseTo(exp, 1);
      });
      return it("returns the weighted mean of the row taking care of missings", function() {
        var exp, row;
        row = {
          ind1: 3,
          ind2: "NA",
          ind3: 8,
          ind4: 9,
          ind5: 1
        };
        exp = (3 * 33.3 + 8 * 33.3) / 66.66;
        return expect(category.mean(row)).toBeCloseTo(exp, 1);
      });
    });
  });

}).call(this);
