// Filename: app.js
define([
  'jquery',
  'underscore',
  'backbone',
  'router',
  'tokenfield',
  'jquery.ui',
  'jquery.ui.tp'
], function($, _, Backbone, Router){
  
  var initialize = function(){
	
	console.log("app.js")
	
	// Prevent scrolling
	$('body').on('touchmove', function (e) {
         if (!$('.scrollable').has($(e.target)).length) e.preventDefault();
	});
	
	// Start routing
	Router.initialize();
	
  };

  return {
    initialize: initialize
  }
  
});
