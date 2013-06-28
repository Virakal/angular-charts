// Generated by CoffeeScript 1.6.2
(function(prefix, name, angular, google) {
  "use strict";
  var app;

  if (prefix == null) {
    prefix = 'gc';
  }
  if (name == null) {
    name = 'chart';
  }
  app = angular.module(name, [function() {}]);
  app.controller('DemoCtrl', [
    '$scope', function($scope) {
      return $scope.chartData = {
        Cake: 12,
        Pizza: 12,
        Burgers: 8,
        'Hot Dogs': 10
      };
    }
  ]);
  app.value(name + '.config', {
    piechart: {
      title: 'Pie Chart'
    }
  });
  app.service('GoogleLibLoader', [
    '$q', '$rootScope', function($q, $rootScope) {
      var load,
        _this = this;

      this.pageLoaded = false;
      this.toLoad = [];
      load = function(spec) {
        var callback, options, originalCallback;

        originalCallback = spec.options.callback;
        callback = function() {
          return $rootScope.$apply(function() {
            spec.promise.resolve();
            return typeof originalCallback === "function" ? originalCallback() : void 0;
          });
        };
        options = angular.extend(spec.options, {
          callback: callback
        });
        return google.load(spec.name, spec.version, options);
      };
      google.setOnLoadCallback(function() {
        var lib, _i, _len, _ref, _results;

        _this.pageLoaded = true;
        _ref = _this.toLoad;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          lib = _ref[_i];
          _results.push(load(lib));
        }
        return _results;
      });
      return {
        require: function(name, version, options) {
          var deferred;

          deferred = $q.defer();
          if (_this.pageLoaded) {
            load({
              name: name,
              version: version,
              options: options,
              promise: deferred
            });
          } else {
            _this.toLoad.push({
              name: name,
              version: version,
              options: options,
              promise: deferred
            });
          }
          return deferred.promise;
        }
      };
    }
  ]);
  app.directive(prefix + 'Piechart', [
    name + '.config', 'GoogleLibLoader', function(config, loader) {
      var toDataTable,
        _this = this;

      toDataTable = function(data) {
        var dt, rows;

        dt = new google.visualization.DataTable();
        rows = [];
        dt.addColumn('string', 'pie1');
        dt.addColumn('number', 'pie2');
        angular.forEach(data, function(value, name) {
          return rows.push([name, parseInt(value, 10)]);
        });
        dt.addRows(rows);
        return dt;
      };
      return {
        restrict: 'E',
        link: function(scope, ele, attrs) {
          return loader.require('visualization', '1.0', {
            'packages': ['corechart']
          }).then(function() {
            var chart, data, dataTable, options;

            options = scope.$eval(attrs.options || {});
            data = scope.$eval(attrs.values || {});
            dataTable = toDataTable(data);
            chart = new google.visualization.PieChart(ele[0]);
            options = angular.extend(config.piechart || {}, options);
            if (attrs.height != null) {
              options.height = parseInt(attrs.height, 10);
            }
            if (attrs.width != null) {
              options.width = parseInt(attrs.width, 10);
            }
            if (attrs.title != null) {
              options.title = attrs.title;
            }
            chart.draw(dataTable, options);
            scope.$watch((function() {
              return scope.$eval(ele.attr(attrs.$attr.values));
            }), function(values) {
              dataTable = toDataTable(values);
              return chart.draw(dataTable, options);
            }, true);
            return attrs.$observe('title', function(title) {
              options.title = title;
              return chart.draw(dataTable, options);
            });
          });
        }
      };
    }
  ]);
  return app.run();
})('gc', 'chart', angular, google);
