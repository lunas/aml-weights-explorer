// Generated by CoffeeScript 1.7.1
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Array.prototype.copy_sort = function(cmp_fct) {
    return this.concat().sort(cmp_fct);
  };

  $(function() {
    var Calculater, Category, Index, Indicator, by_, calculator, filter, get_comparison_data, initialize, model, orig_aml_data, orig_data, orig_data_by_country, orig_data_by_osc, render_ranking, render_scatterplot, scatter_height, scatter_padding, scatter_width, tangle, update_rank;
    scatter_width = 1000;
    scatter_height = 1000;
    scatter_padding = 40;
    tangle = new Tangle(document.getElementById("weights-ui"), {
      initialize: function() {},
      update: function() {}
    });
    window.Index = Index = (function() {
      function Index(variable, initial_weight, cat) {
        this.variable = variable;
        this.initial_weight = initial_weight;
        this.cat = cat;
      }

      Index._indices = null;

      Index._categories = null;

      Index._tangle = null;

      Index.prototype.set_weight = function(value) {
        return Index._tangle.setValue(this.variable, value);
      };

      Index.prototype.get_weight = function() {
        var weight;
        weight = Index._tangle.getValue(this.variable);
        return weight != null ? weight : weight = this.initial_weight;
      };

      Index.prototype.get_osc_weight = function() {
        return Index._tangle.getValue(this.variable + '_osc');
      };

      Index.prototype.reset = function() {
        return this.set_weight(this.initial_weight);
      };

      Index.prototype.update = function() {
        return this.mark_cat(!this.weight_sum_is_100());
      };

      Index.prototype.weight_sum_is_100 = function() {
        return false;
      };

      Index.prototype.mark_cat = function(switch_on) {};

      Index.prototype.selector = function() {
        return '[data-var=' + this.variable + ']';
      };

      Index.prototype.mark = function(switch_on) {
        if (switch_on) {
          return $(this.selector()).addClass('not-100');
        } else {
          return $(this.selector()).removeClass('not-100');
        }
      };

      Index.prototype.near_100 = function(value) {
        return Math.abs(value - 100) < 1;
      };

      Index.set_indices = function(indices) {
        return Index._indices = indices;
      };

      Index.set_categories = function(categories) {
        return Index._categories = categories;
      };

      Index.set_tangle = function(tangle) {
        return Index._tangle = tangle;
      };

      return Index;

    })();
    window.Indicator = Indicator = (function(_super) {
      __extends(Indicator, _super);

      function Indicator() {
        return Indicator.__super__.constructor.apply(this, arguments);
      }

      Indicator.prototype.update = function() {
        this.update_osc_weight();
        return Indicator.__super__.update.apply(this, arguments);
      };

      Indicator.prototype.update_osc_weight = function() {
        var osc_variable;
        osc_variable = this.variable + '_osc';
        return Index._tangle.setValue(osc_variable, this.calculate_osc_weight());
      };

      Indicator.prototype.calculate_osc_weight = function() {
        return this.get_weight() * this.cat.get_weight() / 100;
      };

      Indicator.prototype.weight_sum_is_100 = function() {
        return this.near_100(this.cat.weight_sum());
      };

      Indicator.prototype.mark_cat = function(switch_on) {
        var index, _i, _len, _ref;
        _ref = this.cat.get_my_indices();
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          index = _ref[_i];
          index.mark(switch_on);
        }
        return this.update_cat_weight_sum();
      };

      Indicator.prototype.update_cat_weight_sum = function() {
        var s, selector;
        selector = '.cat-weight-sum.' + this.cat.variable;
        s = 'weight sum: ' + d3.round(this.cat.weight_sum());
        return jQuery(selector).text(s);
      };

      return Indicator;

    })(Index);
    window.Category = Category = (function(_super) {
      __extends(Category, _super);

      function Category() {
        return Category.__super__.constructor.apply(this, arguments);
      }

      Category.prototype.get_my_indices = function() {
        return Index._indices.filter((function(_this) {
          return function(e) {
            return e.cat.variable === _this.variable;
          };
        })(this));
      };

      Category.prototype.weight_sum = function() {
        var sub_indices;
        sub_indices = this.get_my_indices();
        return sub_indices.reduce(function(sum, element) {
          return sum + element.get_weight();
        }, 0);
      };

      Category.prototype.mean = function(row) {
        var sum;
        sum = this.get_my_indices().reduce(function(sum, index) {
          var value;
          value = row[index.variable];
          if (isNaN(value)) {
            return sum;
          }
          sum.total += index.get_weight() * value;
          sum.weight_total += index.get_weight();
          return sum;
        }, {
          total: 0,
          weight_total: 0
        });
        return sum.total / sum.weight_total;
      };

      Category.prototype.all_cat_weight_sum = function() {
        return Index._categories.reduce(function(sum, element) {
          return sum + element.get_weight();
        }, 0);
      };

      Category.prototype.weight_sum_is_100 = function() {
        return this.near_100(this.all_cat_weight_sum());
      };

      Category.prototype.my_indices_weights_are_100 = function() {
        return this.near_100(this.weight_sum());
      };

      Category.prototype.mark_cat = function(switch_on) {
        var cat, _i, _len, _ref;
        _ref = Index._categories;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          cat = _ref[_i];
          cat.mark(switch_on);
        }
        return this.update_all_cat_weight_sum();
      };

      Category.prototype.update_all_cat_weight_sum = function() {
        var s, selector;
        selector = '.cat-weight-sum.osc';
        s = 'weight sum: ' + d3.round(this.all_cat_weight_sum());
        return jQuery(selector).text(s);
      };

      return Category;

    })(Index);
    model = {
      categories: [new Category('ML_TF', 65, 'osc'), new Category('CORRUPTION_RISK', 10, 'osc'), new Category('FIN_TRANSPAR_STD', 15, 'osc'), new Category('PUBLIC_TRANSPAR_ACCOUNT', 5, 'osc'), new Category('POLITICAL_LEGAL_RISK', 5, 'osc')],
      indicators: [],
      initialize: function() {
        var cat, ind, _i, _len, _ref, _results;
        this.indicators = [new Indicator('fatf', 46.15, this.categories[0]), new Indicator('fin_secrecy', 38.46, this.categories[0]), new Indicator('us_incsr', 15.38, this.categories[0]), new Indicator('ti_cpi', 100, this.categories[1]), new Indicator('wb_business_disclosure', 12.5, this.categories[2]), new Indicator('wef_auditing_and_reporting_std', 37.5, this.categories[2]), new Indicator('wef_security_exchange_reg', 37.5, this.categories[2]), new Indicator('wb_fin_sector_reg', 12.5, this.categories[2]), new Indicator('open_budget', 33.33, this.categories[3]), new Indicator('wb_transpar_account_corruption', 33.33, this.categories[3]), new Indicator('idea_political_disclosure', 33.33, this.categories[3]), new Indicator('wef_instit_strength', 33.33, this.categories[4]), new Indicator('rule_of_law', 33.33, this.categories[4]), new Indicator('freedom_house', 33.33, this.categories[4])];
        Index.set_indices(this.indicators);
        Index.set_categories(this.categories);
        Index.set_tangle(tangle);
        _ref = this.indicators;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          ind = _ref[_i];
          this[ind.variable] = ind.get_weight();
          this[ind.variable + '_osc'] = ind.calculate_osc_weight();
          _results.push((function() {
            var _j, _len1, _ref1, _results1;
            _ref1 = this.categories;
            _results1 = [];
            for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
              cat = _ref1[_j];
              _results1.push(this[cat.variable] = cat.initial_weight);
            }
            return _results1;
          }).call(this));
        }
        return _results;
      },
      update: function() {
        var cat, ind, _i, _j, _len, _len1, _ref, _ref1, _results;
        _ref = this.indicators;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          ind = _ref[_i];
          ind.update();
        }
        _ref1 = this.categories;
        _results = [];
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          cat = _ref1[_j];
          _results.push(cat.update());
        }
        return _results;
      }
    };
    tangle.setModel(model);
    window.Calculator = Calculater = (function() {
      function Calculater(indices, categories) {
        this.indices = indices;
        this.categories = categories;
        this.data = [];
      }

      Calculater.prototype.update_country_osc = function() {
        var row, _i, _len, _ref, _results;
        _ref = this.data;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          row = _ref[_i];
          _results.push({
            country: row.country,
            OVERALL_SCORE: this.calculate_osc(row)
          });
        }
        return _results;
      };

      Calculater.prototype.calculate_osc = function(row) {
        var sum;
        sum = this.categories.reduce(function(sum, cat) {
          var cat_mean, weight;
          cat_mean = cat.mean(row);
          if (isNaN(cat_mean)) {
            return sum;
          }
          weight = cat.get_weight();
          sum.total += weight * cat_mean;
          sum.weight_total += weight;
          return sum;
        }, {
          total: 0,
          weight_total: 0
        });
        return sum.total / sum.weight_total;
      };

      Calculater.prototype.calculate_osc_directly = function(row) {
        var sum;
        sum = this.indices.reduce(function(sum, index) {
          var value;
          value = row[index.variable];
          if (isNaN(value)) {
            return sum;
          }
          sum.total += index.get_osc_weight() * value;
          sum.weight_total += index.get_osc_weight();
          return sum;
        }, {
          total: 0,
          weight_total: 0
        });
        return sum.total / sum.weight_total;
      };

      Calculater.prototype.ready = function() {
        var bad_cats;
        if (this.data.length === 0) {
          return false;
        }
        bad_cats = this.categories.filter(function(cat) {
          return !cat.my_indices_weights_are_100();
        });
        return bad_cats.length === 0 && this.categories[0].weight_sum_is_100();
      };

      Calculater.prototype.reset = function() {
        var ind, _i, _len, _ref, _results;
        _ref = this.indices.concat(this.categories);
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          ind = _ref[_i];
          _results.push(ind.reset());
        }
        return _results;
      };

      Calculater.prototype.set_data = function(d) {
        return this.data = d;
      };

      Calculater.prototype.get_indices = function() {
        return this.indices;
      };

      return Calculater;

    })();
    render_ranking = function(selector, data, orig_data) {
      var list;
      list = d3.select(selector + ' table tbody');
      list.selectAll('tr').remove();
      return list.selectAll('tr').data(data).order().enter().append('tr').html(function(row, i) {
        var s;
        s = '<td class="rank">' + orig_data[i].rank + '</td>';
        s += '<td>' + orig_data[i].country + '</td>';
        s += '<td>' + d3.round(orig_data[i].OVERALL_SCORE, 2) + '</td>';
        s += '<td class="rank">' + row.rank + '</td>';
        s += '<td class="country">' + row.country + '</td>';
        return s += '<td>' + d3.round(row.OVERALL_SCORE, 2) + '</td>';
      });
    };
    render_scatterplot = function(data, orig_data) {
      var dataset, svg, x_axis, x_scale, y_axis, y_scale;
      dataset = get_comparison_data(orig_data, data);
      d3.select('#scatter svg').remove();
      svg = d3.select("#scatter").append('svg').attr("width", scatter_width).attr("height", scatter_height);
      x_scale = d3.scale.linear().domain([
        0, d3.max(dataset, function(d) {
          return d.osc_old;
        })
      ]).range([scatter_padding, scatter_width - 3 * scatter_padding]);
      y_scale = d3.scale.linear().domain([
        0, d3.max(dataset, function(d) {
          return d.osc_new;
        })
      ]).range([scatter_height - scatter_padding, scatter_padding]);
      svg.selectAll("circle").data(dataset).enter().append("circle").attr('cx', function(d) {
        return x_scale(d.osc_old);
      }).attr('cy', function(d) {
        return y_scale(d.osc_new);
      }).attr('r', 3);
      svg.selectAll('text').data(dataset).enter().append('text').text(function(d) {
        return d.country + ' ' + d.rank_old + ',' + d.rank_new;
      }).attr({
        'x': function(d) {
          return x_scale(d.osc_old);
        },
        'y': function(d) {
          return y_scale(d.osc_new);
        },
        'font-family': 'sans-serif',
        'font-size': '9px',
        fill: 'blue'
      });
      x_axis = d3.svg.axis().scale(x_scale).orient("bottom");
      y_axis = d3.svg.axis().scale(y_scale).orient("left");
      svg.append('g').attr('class', 'axis').attr('transform', 'translate(0,' + (scatter_height - scatter_padding) + ')').call(x_axis);
      svg.append('g').attr('class', 'axis').attr('transform', 'translate(' + scatter_padding + ', 0)').call(y_axis);
      svg.append('text').attr({
        "class": 'x label',
        'text-anchor': 'end',
        x: scatter_width - 3 * scatter_padding,
        y: scatter_height - 2
      }).text('Overall score based on original AML weighting');
      return svg.append('text').attr({
        "class": 'y label',
        'text-anchor': 'end',
        y: 2,
        dy: '.75em',
        dx: -scatter_padding,
        transform: 'rotate(-90)'
      }).text('Overall score based on adjusted weights');
    };
    by_ = function(key, reverse) {
      if (reverse == null) {
        reverse = false;
      }
      return function(a, b) {
        var ret;
        ret = reverse ? -1 : 1;
        if (a[key] > b[key]) {
          return ret;
        }
        if (a[key] < b[key]) {
          return -ret;
        }
        return 0;
      };
    };
    update_rank = function(data) {
      var rank, row, _i, _len;
      data.sort(by_('OVERALL_SCORE', true));
      rank = 1;
      for (_i = 0, _len = data.length; _i < _len; _i++) {
        row = data[_i];
        row.rank = rank++;
      }
      return data;
    };
    get_comparison_data = function(data_old, data_new) {
      var i, _i, _ref, _results;
      data_old.sort(by_('country'));
      data_new.sort(by_('country'));
      _results = [];
      for (i = _i = 0, _ref = data_old.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        _results.push({
          country: data_old[i].country,
          osc_old: data_old[i].OVERALL_SCORE,
          osc_new: data_new[i].OVERALL_SCORE,
          rank_old: data_old[i].rank,
          rank_new: data_new[i].rank
        });
      }
      return _results;
    };
    filter = function(selector, element) {
      var $rows, $valid, regexp, row_selector;
      row_selector = selector + ' table tr';
      $rows = jQuery(row_selector).hide();
      regexp = new RegExp(jQuery(element).val(), 'i');
      $valid = $rows.filter(function() {
        return regexp.test(jQuery(this).find('td.country').text());
      }).show();
      return $rows.not($valid).hide();
    };
    jQuery('#ranking_osc input.search').on('keyup change', function(e) {
      if (e.keyCode === 27) {
        jQuery(this).val('');
      }
      return filter('#ranking_osc', this);
    });
    jQuery('#ranking_country input.search').on('keyup change', function(e) {
      if (e.keyCode === 27) {
        jQuery(this).val('');
      }
      return filter('#ranking_country', this);
    });
    jQuery('.reset-search').on('click', function(event) {
      jQuery('.search').val('');
      filter('#ranking_osc', this);
      filter('#ranking_country', this);
      event.preventDefault();
      return false;
    });
    d3.select('#update_ranking').on('click', function() {
      var data;
      if (calculator.ready()) {
        data = calculator.update_country_osc();
        data = update_rank(data);
        render_ranking('#ranking_osc', data.sort(by_('OVERALL_SCORE', true)), orig_data_by_osc);
        render_ranking('#ranking_country', data.sort(by_('country')), orig_data_by_country);
        return render_scatterplot(data, orig_data);
      } else {
        return alert('Please make sure the weights add up to 100.');
      }
    });
    d3.select('#reset').on('click', function() {
      calculator.reset();
      return $('#update_ranking').click();
    });
    jQuery('#display').tabs();
    orig_aml_data = null;
    orig_data = orig_data_by_osc = orig_data_by_country = null;
    calculator = new Calculator(Index._indices, Index._categories);
    initialize = function(data) {
      calculator.set_data(data);
      orig_data = calculator.update_country_osc();
      orig_data = update_rank(orig_data);
      orig_data_by_osc = orig_data.copy_sort(by_('OVERALL_SCORE', true));
      orig_data_by_country = orig_data.sort(by_('country'));
      return jQuery('#update_ranking').click();
    };
    return d3.csv("data/aml-public.csv", function(error, data) {
      if (error) {
        return alert(error);
      } else {
        return initialize(data);
      }
    });
  });

}).call(this);
