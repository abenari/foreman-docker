/**
 * @ngdoc object
 * @name  ForemanDocker.registries.controller:NewRegistryController
 *
 * @requires $scope
 * @requires $q
 * @requires FormUtils
 * @requires Registry
 *
 * @description
 *   Controls the creation of an empty Registry object for use by sub-controllers.
 */
angular.module('ForemanDocker.registries').controller('NewRegistryController',
    ['$scope', '$q', 'FormUtils', 'Registry',
    function ($scope, $q, FormUtils, Registry) {

        function success(response) {
            $scope.table.addRow(response);
            $scope.transitionTo('registries.details.info', {registryId: $scope.registry.id});
        }

        function error(response) {
            $scope.working = false;
            angular.forEach(response.data.errors, function (errors, field) {
                $scope.registryForm[field].$setValidity('server', false);
                $scope.registryForm[field].$error.messages = errors;
            });
        }

        $scope.registry = $scope.registry || new Registry();

        $scope.panel = {loading: false};

        $scope.save = function (registry) {
            registry.$save(success, error);
        };

    }]
);
