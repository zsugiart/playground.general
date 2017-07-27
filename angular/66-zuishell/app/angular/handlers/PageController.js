'use strict';

/**
 * @ngdoc controller
 * @name izzyposWebApp.directive:adminPosHeader
 * @description
 * # adminPosHeader
 */
_MODULE
	.controller('PageController',function($scope, PageService, UIRouterStateProvider){
		console.log("Page Controller initiation logic");
		
		PageService.config("log.debug",true);
		PageService.appTitle = "ZB-APP";
		
		// bounds Service into the page scope as PAGE
		$scope.PAGE=PageService;
		
		// construct the menu
    	// see app.js for list of UISREF router
    	
    	PageService.helloWorld();
		PageService.addMenuSection("main","Main Menu")
		PageService.addMenuItem("main","Hello","pages.helloView");
		PageService.addMenuItem("main","Blank","pages.blank");
		
		PageService.addNotification("system","all good")
	});