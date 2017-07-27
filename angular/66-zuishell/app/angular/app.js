'use strict';
/**
 * @ngdoc overview
 * @name sbAdminApp
 * @description
 * # sbAdminApp
 *
 * Main module of the application accessible as global variable _MODULE
 * _MODULE
 */

// ID of this application, configure appropriately in index.html
var _APPID 		= "ZB-APP-ID";
var _APPNAME	= "ZB-AppName"

// main angular module
var _MODULE = angular.module(_APPID, [
    'oc.lazyLoad',
    'ui.router',
    'ui.bootstrap',
    'angular-loading-bar',
  ])
  .config(['$stateProvider','$urlRouterProvider','$ocLazyLoadProvider', 
           function ($stateProvider,$urlRouterProvider,$ocLazyLoadProvider) { 
	  
    $ocLazyLoadProvider.config({
      debug:false,	// set to true for debug mode
      events:true,	// set to true to enable events
    });

    // default URL to set if none is set
    $urlRouterProvider.otherwise('/pages/helloView');
   
    // state config: main/parent page
    // ------------------------------
    $stateProvider
      .state('pages', {
        url:'/pages',
        templateUrl: 'angular/views/pages.html',
        controller: 'PageController',
        resolve: {
            configInit:function($ocLazyLoad)
            {
                $ocLazyLoad.load({
                    name:_APPID,
                    files:[
                           
                    // CORE SERVICE & CONTROLLER - try not to customize this
                    'angular/handlers/PageService.js',
                    'angular/handlers/PageController.js', 	// main
                    
                    // SHARED DIRECTIVES - extend as necessary
                    
                    'angular/directives/header/header.js',
                    'angular/directives/header/header-notification/header-notification.js',
                    'angular/directives/sidebar/sidebar.js',
                    'angular/directives/sidebar/sidebar-search/sidebar-search.js',
                    
                    // APPLICATION CONTROLLERS - add your own
                    
                    'angular/views/pages/blankController.js',		// controller for blank page
                    'angular/views/pages/helloViewController.js'		// controller for blank page
                    
                    ]
                })
                $ocLazyLoad.load(
                {
                   name:'toggle-switch',
                   files:["bower_components/angular-toggle-switch/angular-toggle-switch.min.js",
                          "bower_components/angular-toggle-switch/angular-toggle-switch.css"
                      ]
                })
                $ocLazyLoad.load(
                {
                  name:'ngAnimate',
                  files:['bower_components/angular-animate/angular-animate.js']
                })
                $ocLazyLoad.load(
                {
                  name:'ngCookies',
                  files:['bower_components/angular-cookies/angular-cookies.js']
                })
                $ocLazyLoad.load(
                {
                  name:'ngResource',
                  files:['bower_components/angular-resource/angular-resource.js']
                })
                $ocLazyLoad.load(
                {
                  name:'ngSanitize',
                  files:['bower_components/angular-sanitize/angular-sanitize.js']
                })
                $ocLazyLoad.load(
                {
                  name:'ngTouch',
                  files:['bower_components/angular-touch/angular-touch.js']
                })
            }, // --end:configInit
          
            menuInit: function(){
            	
            }
        } // resolve
       }) //./state{.pages}
       
       // PAGES ROUTING
       // Make sure controllers are registered in above config lazy loading
       // -------------
      
      $stateProvider.state('login',{
           templateUrl:'angular/views/pages/login.html',
           url:'/login'
           })

      $stateProvider.state('pages.helloView',{
           templateUrl:'angular/views/pages/helloView.html',
           controller: 'HelloViewController',
           url:'/helloView'
           })

      $stateProvider.state('pages.blank',{
           templateUrl:	'angular/views/pages/blank.html',
           url:			'/blank',
           controller:	'BlankPageController',
           });
           
  }
  ]) // end config
