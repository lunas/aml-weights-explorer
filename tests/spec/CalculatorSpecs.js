// Generated by CoffeeScript 1.7.1
(function() {
  describe("Calculator", function() {
    var calc, category, category2, ind1, ind2, ind3, ind4, ind5, ind6, indices, tangle;
    calc = category = category2 = ind1 = ind2 = ind3 = ind4 = ind5 = ind6 = tangle = indices = null;
    beforeEach(function() {
      category = new Category('cat', 80, 'osc');
      category2 = new Category('cat2', 20, 'osc');
      ind4 = new Indicator('ind4', 34, category2);
      ind1 = new Indicator('ind1', 50, category);
      ind2 = new Indicator('ind2', 25, category);
      ind3 = new Indicator('ind3', 25, category);
      ind5 = new Indicator('ind5', 33, category2);
      ind6 = new Indicator('ind6', 33, category2);
      tangle = {
        setValue: function(variable, value) {},
        getValue: function(variable) {
          return 0.5;
        }
      };
      Index.set_tangle(tangle);
      Index.set_indices([ind1, ind2, ind3, ind4, ind5, ind6]);
      Index.set_categories([category, category2]);
      return calc = new Calculator(Index._indices);
    });
    describe('constructor', function() {
      it('has a list of indicators', function() {
        return expect(calc.indices).toEqual(Index._indices);
      });
      return it('has an empty data attribute', function() {
        return expect(calc.data).toEqual([]);
      });
    });
    describe('calculate_osc', function() {
      it('calculates weighted average of a row based on the osc-weights specified for the indices', function() {
        var expected, row;
        row = {
          ind1: 1,
          ind2: 2,
          ind3: 3,
          ind4: 4,
          ind5: 5,
          ind6: 6
        };
        expected = 0.5 * (1 + 2 + 3 + 4 + 5 + 6) / (6 * 0.5);
        return expect(calc.calculate_osc(row)).toEqual(expected);
      });
      return it('calculates weighted average taking care of missings', function() {
        var expected, row;
        row = {
          ind1: 1,
          ind2: NaN,
          ind3: 3,
          ind4: "NA",
          ind5: 5,
          ind6: 6
        };
        expected = 0.5 * (1 + 3 + 5 + 6) / (4 * 0.5);
        return expect(calc.calculate_osc(row)).toEqual(expected);
      });
    });
    return describe('update_coutry_osc', function() {
      var data;
      data = [];
      beforeEach(function() {
        data = [
          {
            country: 'Afghanistan',
            ind1: 1,
            ind2: 2,
            ind3: 3,
            ind4: 4,
            ind5: 5,
            ind6: 6
          }, {
            country: 'Zimbabwe',
            ind1: 1,
            ind2: NaN,
            ind3: 3,
            ind4: "NA",
            ind5: 5,
            ind6: 6
          }
        ];
        return calc.set_data(data);
      });
      return it('returns a array of {country, OVERALL_SCORE} objects', function() {
        return expect(calc.update_country_osc()).toEqual([
          {
            country: 'Afghanistan',
            OVERALL_SCORE: 3.5
          }, {
            country: 'Zimbabwe',
            OVERALL_SCORE: 3.75
          }
        ]);
      });
    });
  });

}).call(this);
