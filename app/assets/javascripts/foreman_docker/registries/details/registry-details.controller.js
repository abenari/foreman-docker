/**
 * @ngdoc object
 * @name  ForemanDocker.registries.controller:RegistryDetailsController
 *
 * @requires $scope
 * @requires $state
 * @requires $q
 * @requires translate
 * @requires Registry
 *
 * @description
 *   Provides the functionality for the registry details action pane.
 */
angular.module('ForemanDocker.registries').controller('RegistryDetailsController',
    ['$scope', '$state', '$q', 'translate', 'Registry',
    function ($scope, $state, $q, translate, Registry) {
        $scope.successMessages = [];
        $scope.errorMessages = [];

        if ($scope.registry) {
            $scope.panel = {loading: false};
        } else {
            $scope.panel = {loading: true};
        }

        $scope.registry = Registry.get({id: $scope.$stateParams.registryId}, function (registry) {
            $scope.$broadcast('registry.loaded', registry);
            $scope.panel.loading = false;
        });

        $scope.save = function (registry) {
            var deferred = $q.defer();

            registry.$update(function (response) {
                deferred.resolve(response);
                $scope.successMessages.push(translate('Registry updated'));
                $scope.table.replaceRow(response);
            }, function (response) {
                deferred.reject(response);
                $scope.errorMessages.push(translate("An error occurred saving the Registry: ") + response.data.displayMessage);
            });
            return deferred.promise;
        };

        $scope.setRegistry = function (registry) {
            $scope.registry = registry;
        };

        $scope.removeRegistry = function (registry) {
            var id = registry.id;

            registry.$delete(function () {
                $scope.removeRow(id);
                $scope.transitionTo('registries.index');
                $scope.successMessages.push(translate('Registry removed.'));
            }, function (response) {
                $scope.errorMessages.push(translate("An error occurred removing the Registry: ") + response.data.displayMessage);
            });
        };
    }]
);
