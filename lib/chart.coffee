((prefix, name, angular, google) ->
    "use strict"

    # Provide some default values for the app name and directive prefix
    # just to be safe :)
    prefix ?= 'gc'
    name ?= 'chart'

    # Build a module with the given module name
    app = angular.module name, [->]

    # This provides a global config value for the user to override.
    app.value name + '.config', {}

    app.service 'GoogleLibLoader', ['$q', '$rootScope', ($q, $rootScope) ->
        # This largely exists to get around the awkward fact that the
        # Google Loader will completely destroy the page if you call it
        # after the DOM has loaded unless you specifify a callback.
        #
        # It also ensures callbacks are applied to scope and ties in
        # with the $q promise API a little more nicely.

        @pageLoaded = false
        @toLoad = []

        load = (spec) ->
            # This takes the originally specified callback and decorates
            # it, applying the callback to the scope and also resolving
            # its promise.
            #
            # It also has the "side-effect" of stopping google from
            # destroying the page as all calls will now have a callback.

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
            # This is the main API function. Its signature matches that of
            # google.load() and effectively passes the options directly
            # to it, but with an overwritten callback function.

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
            # This builds a Google DataTable object from the given values.

            dt = new google.visualization.DataTable()
            rows = []

            # In the pie chart's case, the name of the columns are irrelevant
            # and the types are always going to be string and number,
            # so we can just hard code them.

            dt.addColumn 'string', 'pie1'
            dt.addColumn 'number', 'pie2'

            angular.forEach data, (value, name) ->
                rows.push [name, parseInt(value, 10)]

            dt.addRows rows

            return dt

        restrict: 'E'
        link: (scope, ele, attrs) =>
            # The loader lets us require a Google Library and use it like a
            # promise.
            loader.require('visualization', '1.0', {'packages': ['corechart']}).then ->

                # The scope.$eval allows for interpolation, scope variables, etc.
                options = scope.$eval attrs.options || {}
                data = scope.$eval attrs.values || {}
                dataTable = toDataTable data
                chart = new google.visualization.PieChart ele[0]

                # Build the options object for the chart
                options = angular.extend config.piechart || {}, options
                options.height = parseInt attrs.height, 10 if attrs.height?
                options.width = parseInt attrs.width, 10 if attrs.width?
                options.title = attrs.title if attrs.title?

                chart.draw dataTable, options

                scope.$watch(
                    (() ->
                        # Accepting objects or a variable name is quite an
                        # ugly process, especially when you want to
                        # react to changes in the object!
                        scope.$eval ele.attr attrs.$attr.values
                    ), (values) -> (
                        # This assigns the new datatable to the outer scope
                        # by design. This way chages to options will not
                        # overwrite them.
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
# Parameters are passed in here:
#   Directive prefix
#   Module name
#   The AngularJS instance
#   The Google JSAPI instance
