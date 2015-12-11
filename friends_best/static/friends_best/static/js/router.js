// Filename: router.js
define([
  'jquery',
  'underscore',
  'backbone',
  'views/home/main',
  'views/search/history',
  'views/recommend/add',
  'views/search/results',
], function($, _, Backbone, HomeView, HistoryView, RecommendView, ResultsView){
	
	var AppRouter = Backbone.Router.extend({
	    routes: {
			"": 					"main",				// #
			"search/:queryid":		"search",			// #search/id
			"search":				"searchhistory",	// #search
			"recommend":			"recommend"			// #recommend
		},
		render: function(view) {
			// Close the current view
	        if (this.currentView) {
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
		
		Backbone.history.start();
		
		console.log("router.js")
		
		return app_router
	};
  
	return {
		initialize: initialize,
	};
  
});