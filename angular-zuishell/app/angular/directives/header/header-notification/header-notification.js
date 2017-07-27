'use strict';

/**
 * @ngdoc directive
 * @name izzyposWebApp.directive:adminPosHeader
 * @description
 * # adminPosHeader
 */
_MODULE
	.directive('headerNotification',function(){
		return {
        templateUrl:'angular/directives/header/header-notification/header-notification.html',
        restrict: 'E',
        replace: true,
        link: function() {
        	console.log("link function header notification");
    	}
	}
	});


