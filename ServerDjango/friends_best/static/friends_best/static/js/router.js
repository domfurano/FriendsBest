// Filename: router.js
define([
  'jquery',
  'underscore',
  'backbone',
  'views/home/main',
  'views/search/history',
  'views/recommend/add',
  'views/search/results',
  'views/home/login',
], function($, _, Backbone, HomeView, HistoryView, RecommendView, ResultsView, LoginView){
	
	var AppRouter = Backbone.Router.extend({
	    routes: {
			"": 					"main",				// #
			"search/:queryid":		"search",			// #search/id
			"search/:queryid/:sid":	"search",			// #search/id
			"search":				"searchhistory",	// #search
			"recommend":			"recommend",		// #recommend
			"login":				"login"				// #login
		},
		render: function(view) {
			// Close the current view
	        if (this.currentView) {
		        console.log("remove exisiting view");
	            this.currentView.remove();
	        }
	
	        // Render the new view
	        view.render();
	
	        // Set the current view
	        this.currentView = view;
	
	        return this;
		}
	});

	var initialize = function(){
		
		var app_router = new AppRouter;
		
		app_router.on('route:main', function(){
			this.render(new HomeView());
		});
		
		app_router.on('route:searchhistory', function(){
			this.render(new HistoryView());
		});
		
		app_router.on('route:search', function(queryid){
			this.render(new ResultsView({id: queryid}));
		});
		
		app_router.on('route:recommend', function(){
			this.render(new RecommendView());
		});
		
		app_router.on('route:login', function(){
			this.render(new LoginView());
		});
		
		// Check login status
		FB.getLoginStatus(function(response) {
			console.log(response);
			
			
			
			// Navigate to login if not authorized
			if(response.status === "connected") {
				// Logged in
				// Submit the token to API
				
				$.post("/fb/api/facebook/", {'access_token' : response.authResponse.accessToken}, function(data) {
					token = data.key;
					
					Backbone.$.ajaxSetup({
					    headers: { 'Authorization' :'Token ' + token }
					});
					
					// Start routing
					Backbone.history.start();
					
				});
				
			} else {
				console.log("not authorized.");
				// Start routing
				Backbone.history.start();
				app_router.navigate("login", {trigger: true});
			}
			
		}, true);
		
		console.log("router.js");
		
		return app_router;
	};
  
	return {
		initialize: initialize,
	};
  
});