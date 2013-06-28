((prefix, name, angular, google) ->
    "use strict"

    prefix ?= 'gc'
    name ?= 'chart'

    app = angular.module name, [->]

    app.controller 'DemoCtrl', ['$scope', ($scope) ->
        $scope.chartData =
            Cake: 12
            Pizza: 12
            Burgers: 8
            'Hot Dogs': 10
    ]

    app.value name + '.config',
        piechart:
            title: 'Pie Chart'

    app.service 'GoogleLibLoader', ['$q', '$rootScope', ($q, $rootScope) ->
        @pageLoaded = false
        @toLoad = []

        load = (spec) ->
            originalCallback = spec.options.callback

            callback = () ->
                $rootScope.$apply ->
                    spec.promise.resolve()
                    originalCallback?()

            options = angular.extend spec.options, {callback: callback}

            google.load spec.name, spec.version, options

        google.setOnLoadCallback =>
            @pageLoaded = true
            load lib for lib in @toLoad


        require: (name, version, options) =>
            deferred = $q.defer()
            if @pageLoaded
                load
                    name: name
                    version: version
                    options: options
                    promise: deferred
            else
                @toLoad.push
                    name: name
                    version: version
                    options: options
                    promise: deferred

            return deferred.promise
    ]

    app.directive prefix + 'Piechart', [name + '.config', 'GoogleLibLoader', (config, loader) ->
        toDataTable = (data) ->
            dt = new google.visualization.DataTable()
            rows = []

            dt.addColumn 'string', 'pie1'
            dt.addColumn 'number', 'pie2'

            angular.forEach data, (value, name) ->
                rows.push [name, parseInt(value, 10)]

            dt.addRows rows

            return dt

        restrict: 'E'
        link: (scope, ele, attrs) =>
            loader.require('visualization', '1.0', {'packages': ['corechart']}).then ->
                options = scope.$eval attrs.options || {}
                data = scope.$eval attrs.values || {}
                dataTable = toDataTable data
                chart = new google.visualization.PieChart ele[0]

                options = angular.extend config.piechart || {}, options
                options.height = parseInt attrs.height, 10 if attrs.height?
                options.width = parseInt attrs.width, 10 if attrs.width?
                options.title = attrs.title if attrs.title?

                chart.draw dataTable, options

                scope.$watch(
                    (() ->
                        scope.$eval ele.attr attrs.$attr.values
                    ), (values) -> (
                        dataTable = toDataTable values

                        chart.draw dataTable, options
                    )
                , true)

                attrs.$observe 'title', (title) ->
                    options.title = title

                    chart.draw dataTable, options

                # scope.$watch attrs.options, (options) ->
                #     chart.draw dataTable, options

    ]

    app.run()
)('gc', 'chart', angular, google)