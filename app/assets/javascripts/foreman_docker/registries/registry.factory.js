/**
 * @ngdoc service
 * @name  ForemanDocker.registries.factory:Registry
 *
 * @requires BastionResource
 *
 * @description
 *   Provides a BastionResource for a registry or list of registries.
 */
angular.module('ForemanDocker.registries').factory('Registry',
    ['BastionResource', function (BastionResource) {

        return BastionResource('/docker/api/v2/registries/:id/:action', {id: '@id'}, {
            update: { method: 'PUT'},
            autocomplete: {method: 'GET', isArray: true, params: {id: 'auto_complete_search'}}
        });

    }]
);
