/**
 * @ngdoc module
 * @name  ForemanDocker.registries
 *
 * @description
 *    Module for registries
 */
angular.module('ForemanDocker.registries', [
    'ngResource',
    'ui.router',
    'Bastion',
    'Bastion.components',
    'Bastion.components.formatters'
]);

/**
 * @ngdoc object
 * @name ForemanDocker.registries.config
 *
 * @requires $stateProvider
 *
 * @description
 *   Used for registries level configuration such as setting up the ui state machine.
 */
angular.module('ForemanDocker.registries').config(['$stateProvider', function ($stateProvider) {
    $stateProvider.state('registries', {
        abstract: true,
        controller: 'RegistriesController',
        templateUrl: 'registries/views/registries.html'
    });

    $stateProvider.state('registries.index', {
        url: '/registries',
        permission: 'view_registries',
        views: {
            'table': {
                templateUrl: 'registries/views/registries-table-full.html'
            }
        }
    })
    .state('registries.new', {
        url: '/registries/new',
        permission: 'create_registries',
        collapsed: true,
        views: {
            'table': {
                templateUrl: 'registries/views/registries-table-collapsed.html'
            },
            'action-panel': {
                controller: 'NewRegistryController',
                templateUrl: 'registries/new/views/registry-new.html'
            }
        }
    });

    $stateProvider.state('registries.details', {
        abstract: true,
        url: '/registries/:registryId',
        permission: 'view_registries',
        collapsed: true,
        views: {
            'table': {
                templateUrl: 'registries/views/registries-table-collapsed.html'
            },
            'action-panel': {
                controller: 'RegistryDetailsController',
                templateUrl: 'registries/details/views/registry-details.html'
            }
        }
    })
    .state('registries.details.info', {
        url: '/info',
        permission: 'view_registries',
        collapsed: true,
        controller: 'RegistryDetailsInfoController',
        templateUrl: 'registries/details/views/registry-info.html'
    });
}]);
