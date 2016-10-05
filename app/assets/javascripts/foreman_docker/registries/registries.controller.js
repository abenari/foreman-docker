/**
 * @ngdoc object
 * @name  ForemanDocker.registries.controller:RegistriesController
 *
 * @requires $scope
 * @requires $location
 * @requires Nutupane
 * @requires Registry
 *
 * @description
 *   Provides the functionality specific to Registries for use with the Nutupane UI pattern.
 *   Defines the columns to display and the transform function for how to generate each row
 *   within the table.
 */
angular.module('ForemanDocker.registries').controller('RegistriesController',
    ['$scope', '$location', 'Nutupane', 'Registry',
    function ($scope, $location, Nutupane, Registry) {

        var params = {
            'search': $location.search().search || "",
            'sort_by': 'name',
            'sort_order': 'ASC',
            'paged': true
        };

        var nutupane = new Nutupane(Registry, params);
        $scope.table = nutupane.table;
        $scope.removeRow = nutupane.removeRow;
        $scope.controllerName = 'foreman_docker_registries';

        $scope.table.closeItem = function () {
            $scope.transitionTo('registries.index');
        };
    }]
);
