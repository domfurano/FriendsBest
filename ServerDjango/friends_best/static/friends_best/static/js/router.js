// Filename: router.js
define([
  'jquery',
  'underscore',
  'backbone',
  'views/home/menu',
  'views/home/main',
  'views/search/history',
  'views/recommend/recommend',
  'views/search/results',
  'views/home/login',
  'views/profile/profile',
  'views/profile/recommendations',
  'views/profile/friends'
], function($, _, Backbone, MenuView, HomeView, HistoryView, RecommendView, ResultsView, LoginView, ProfileMenu, RecommendationsView, FriendsView){
	
	var AppRouter = Backbone.Router.extend({
	    routes: {
			"": 						"main",				// #
			"search/:queryid":			"search",			// #search/id
			"search/:queryid/:sid":		"search",			// #search/id
			"search":					"searchhistory",	// #search
			"recommend":				"recommend",		// #recommend
			"login":					"login",			// #login
			"profile":					"profile",			// #profile
			"profile/recommendations":	"recommendations",	// #profile/recommendations
			"profile/friends":			"friends",			// #profile/friends
			"loggedin":                 "loggedin"
		},
		initialize: function() {
		},
		render: function(view, menu) {
			
			if(typeof this.menu === "undefined") {
				// Setup nav menu
				this.menu = new MenuView();
				this.menu.render();
			}
			
			// Close the current view
	        if (this.currentView) {
		        console.log("remove exisiting view");
	            this.currentView.remove();
	        } else {
		        $(".view").html("");
	        }
	        
	        menu ? this.menu.show() : this.menu.hide();
	
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
			this.render(new HomeView({tutorial: false}), true);
		});
		
		app_router.on('route:searchhistory', function(){
			this.render(new HistoryView(), true);
		});
		
		app_router.on('route:search', function(queryid){
			this.render(new ResultsView({id: queryid}), true);
		});
		
		app_router.on('route:recommend', function(){
			this.render(new RecommendView());
		});
		
		app_router.on('route:loggedin', function(){
    		this.render(new HomeView({tutorial: true}), true);
		});
		
		app_router.on('route:login', function(){
			login = new LoginView();
			$(".view").html("");
			login.render();
			this.currentView = login;
		});
		
		app_router.on('route:profile', function(){
			this.render(new ProfileMenu(), true);
		});
		
		app_router.on('route:recommendations', function(page){
			this.render(new RecommendationsView(), true);
		});
		
		app_router.on('route:friends', function(page){
			this.render(new FriendsView(), true);
		});
		
		// Check login status
		FB.getLoginStatus(function(response) {

			// Navigate to login if not authorized
			if(response.status === "connected") {
				// Logged in
				
				// Get the Facebook Photo
				FB.image = $("<img>").attr("src", "https://graph.facebook.com/v2.5/" + response.authResponse.userID + "/picture?type=large");
				
				// Submit the token to API
				$.post("/fb/api/facebook/", {'access_token' : response.authResponse.accessToken}, function(data) {
					token = data.key;
					
					Backbone.$.support.cors = true;
					
					Backbone.$.ajaxSetup({
					    //headers: { 'Authorization' :'Token ' + token },
					    beforeSend: function(jqXHR) {
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
				window.location = "#login";
                Backbone.history.start();
			}
			
		}, true);
		
		console.log("router.js");
		
		return app_router;
	};
  
	return {
		initialize: initialize,
	};
  
});