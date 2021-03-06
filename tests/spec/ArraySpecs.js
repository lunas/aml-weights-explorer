// Generated by CoffeeScript 1.7.1
(function() {
  describe("Array", function() {
    var ar, cmp, sorted;
    ar = cmp = sorted = null;
    beforeEach(function() {
      ar = [
        {
          x: 20
        }, {
          x: 9
        }, {
          x: 2
        }, {
          x: 23
        }, {
          x: 13
        }
      ];
      cmp = function(a, b) {
        return a.x - b.x;
      };
      return sorted = ar.copy_sort(cmp);
    });
    return describe('copy_sort', function() {
      it('returns the sorted array', function() {
        var i, _i, _ref, _results;
        expect(sorted.length).toEqual(ar.length);
        _results = [];
        for (i = _i = 0, _ref = sorted.length - 2; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
          _results.push(expect(sorted[i].x).toBeLessThan(sorted[i + 1].x));
        }
        return _results;
      });
      return it('does not mutate the array to be sorted', function() {
        return expect(ar[0].x).toBe(20);
      });
    });
  });

}).call(this);
