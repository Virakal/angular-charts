app = angular.module 'gauge', ['chart']

app.controller 'GaugeCtrl', ['$scope', ($scope) ->
    $scope.revs = 1500
    $scope.mph = 30
]

app.value 'chart.config',
    gauge:
        animation:
            duration: 300
            easing: 'in'
