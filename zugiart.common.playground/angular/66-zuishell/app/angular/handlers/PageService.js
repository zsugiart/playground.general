'use strict';

/**
 * Service to control the main application frame
 * such as setting title, menu and notification system, etc
 * @ngdoc service
 * @name 
 * @description
 */
_MODULE
	.service('PageService', [ '$rootScope', function ($rootScope ) {
	
	// for storing all kind of config
	var _config = {};
		
	var _service = {
			
		// title of the application
		appTitle:null,
		
		// title of the page
		pageTitle:null,
		
		// for holding notifications
		notificationList:[],
		
		// for holding all kinds of configuration
		_config:{},
		
		// for holding menu
		menuList:[],
		_menuIndex:{}, // for quick access
		
		// user session
		userSession:null,
		
		//========================== internal/helper functions ==================== //
		
		// says hello
		helloWorld: function() {
			_service._log("helloWorld");
		},
		
		/**
		 * Gets the config if value is null
		 * If value is not null, sets the config. 
		 */
		config: function(param,value) {
			if ( value == null ) return _config[param];
			else return _config[param]=value;
		},
		
		_log: function(msg) {
			if( _config['log.debug'] )
				console.log("PageService: "+msg);
		},
		
		//========================== user authentication ========================== //
		
		/** 
		 * authenticate a user, and return the currently logged in user record 
		 */
		authenticate: function(username,password) {
			
			// authenticate here, and populate the _userSession object below
			
			_service.userSession = {
				'username':username,
				'lastLogin':new Date(),
				'params': {}
				}
			return _service.userSession;
		},
		
		
		
		/** set user parameter **/
		setParam: function(key,value){
			if ( _service.userSession == null ) throw "User Session not yet initiated";
			return _service.userSession[key]=value;
		},
		
		/** logout a user and remove their user session **/
		logout: function() {
		},
		
		// ======================== Page Notification ============================ //
	
		// add notification
		addNotification: function(from,message){
			var rec = {'from':from, 'msg':message, 'time':new Date()};
			_service._log("adding notification: from="+rec.from+", msg="+rec.msg);
			// INSERT NOTIFICATION LOGIC HERE // system fetch, etc
			_service.notificationList.push(rec);
		},
		
		getNotificationList: function() {
			// INSERT NOTIFICATION LOGIC HERE / DB Query / etc
			return _service.notificationList;
		},
		
		/**
		 * Adds a menu section, displayed in order of insertion
		 */
		addMenuSection: function(sectionID,sectionLabel)
		{
			_service._menuIndex[sectionID]=[];
			_service.menuList.push({'sectionID':sectionID,'label':sectionLabel,'items':_service._menuIndex[sectionID]});
		},
		
		/**
		 * Adds a menu into the page. Example: 
		 * PageService.addMenu("/Group1/This","This Page","/pages/this");
		 * PageService.addMenu("/Group1/That","That Page","/pages/that");
		 * #Menu:
		 * Group1
		 *  '-This
		 *  '-That
		 */
		addMenuItem: function(sectionID,label,uisref){
			if ( label == null || uisref == null ) throw "group or uisref can't be null when adding menu";
			var rec={'label':label,'uisref':uisref};
			_service._log("adding menu: sectionID="+sectionID+" // "+rec.uisrefl);
			var menuSection = _service._menuIndex[sectionID];
			if( menuSection == undefined ) throw "Section ID "+sectionID+" does not exist";
			menuSection.push(rec);
		},
		
		getMenuList: function(){
			for ( var menuSection in _service.menuList )
			{
				for( var menuItem in menuSection.items ){
					_service._log("   > "+menuItem.label+" : "+menuItem.uisref);
				}
			}
			return _service.menuList;
		}
	}
	return _service;
	}]);


/**
 * Allows for dynamically adding state
 */
_MODULE.provider('UIRouterStateProvider', function runtimeStates($stateProvider) {
  // runtime dependencies for the service can be injected here, at the provider.$get() function.
  this.$get = function($q, $timeout, $state) { // for example
    return { 
      addState: function(name, state) { 
        $stateProvider.state(name, state);
      }
    }
  }
});