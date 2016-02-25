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
  'views/profile/menu',
], function($, _, Backbone, HomeView, HistoryView, RecommendView, ResultsView, LoginView, ProfileMenu){
	
	var AppRouter = Backbone.Router.extend({
	    routes: {
			"": 					"main",				// #
			"search/:queryid":		"search",			// #search/id
			"search/:queryid/:sid":	"search",			// #search/id
			"search":				"searchhistory",	// #search
			"recommend":			"recommend",		// #recommend
			"login":				"login",			// #login
			"profile":				"profile"			// #profile
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
		
		var _sync = Backbone.sync;
        Backbone.sync = function(method, model, options){
        
            // Add trailing slash to backbone model views
            var _url = _.isFunction(model.url) ?  model.url() : model.url;
            _url += _url.charAt(_url.length - 1) == '/' ? '' : '/';
        
            options = _.extend(options, {
                url: _url
            });
        
            return _sync(method, model, options);
        };
		
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
		
		app_router.on('route:profile', function(){
			this.render(new ProfileMenu());
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
					
					Backbone.$.support.cors = true;
					
					Backbone.$.ajaxSetup({
					    //headers: { 'Authorization' :'Token ' + token },
					    beforeSend: function(jqXHR) {
    					    console.log(jqXHR);
                            jqXHR.setRequestHeader('Authorization', 'Token ' + token);
                            jqXHR.setRequestHeader('SomeData', 'Token ' + token);
                        }
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