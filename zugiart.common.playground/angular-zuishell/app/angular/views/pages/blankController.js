'use strict';

/**
 * @ngdoc controller
 * @name izzyposWebApp.directive:adminPosHeader
 * @description
 * # adminPosHeader
 */
_MODULE
	.controller('BlankPageController',function($scope, $document, PageService){
		
		$scope.init = function(){

			PageService.addNotification("BlankPage","You are viewing this page");

			PageService.addNotification("BlankPage","You are viewing this page AGAIN");
			
		};
		
		PageService.pageTitle = "Blank Page"
		$scope.init();
	});