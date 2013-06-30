(() -> (
    app = angular.module 'piechart', ['chart']

    app.controller 'PieChartCtrl', ['$scope', ($scope) ->
        $scope.chartData =
            'Cake': 12
            'Pizza': 12
            'Burgers': 8
            'Hot Dogs': 10
    ]

    app.value name + '.config',
        piechart:
            title: 'Pie Chart'
))()