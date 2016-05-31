'use strict';

/**
 * @ngdoc directive
 * @name izzyposWebApp.directive:adminPosHeader
 * @description
 * # adminPosHeader
 */
_MODULE
	.directive('header',function(PageService){
		return {
        templateUrl:'angular/directives/header/header.html',
        restrict: 'E',
        replace: true,
        link: function(scope,element,attr){
        	
        	// activate SIDR menu
    		$(document).ready(function() {
				var menuObj = $("#simple-menu");
				$('#simple-menu').sidr({'name':'sidr'});
				
				// if mouse leave #sidr div
				$('#sidr').mouseout(function(e) {
				    if (e.offsetX < 0 || e.offsetX > $(this).width()) {
				    	$.sidr('close', 'sidr');
				    }
				});
			});
				
        	}
    	}
	});


