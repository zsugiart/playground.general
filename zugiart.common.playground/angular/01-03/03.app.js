var app = angular.module('myApp', []);
app.controller('myCtrl', function($scope) {
	// initiation of the ng-bind vars
	$scope.d_accountList = [
		{ 'id':'zboo1', 'name':'Zeni BooBoo 1', 'balance':76500},
		{ 'id':'zboo2', 'name':'ZeeZee BaaBoo2', 'balance':767} 
	];
});