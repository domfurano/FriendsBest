// Filename: app.js
define([
  'jquery',
  'underscore',
  'backbone',
  'router',
  'views/home/login',
  'fb',
  'tokenfield',
  'jquery.ui',
  'jquery.ui.tp'
], function($, _, Backbone, Router, LoginView){
  
  var initialize = function(){
	
	console.log("app.js")
	
	// Prevent scrolling
	$('body').on('touchmove', function (e) {
         if (!$('.scrollable').has($(e.target)).length) e.preventDefault();
	});
	
	// Route to correct page.
	this.router = Router.initialize();
	
  };

  return {
    initialize: initialize
  }
  
});
