define([
  'jquery',
  'underscore',
  'backbone',
  'app',
  'views/recommend/add',
  'views/search/results',
  'models/query',
  'text!templates/home/login.html',
  'fb'
], function($, _, Backbone, App, Recommend, ResultsView, QueryModel, loginHTML){

  var HomeView = Backbone.View.extend({
    el: $(".view"),

    render: function(){
      
		var loginTemplate = _.template( loginHTML, {} );
		this.$el.html(loginTemplate);
		
		$(".fb-login-button").click(function() {
			FB.login(function(response) {
				// The response contains the token that needs to be sent to the server
				if (response.authResponse) {
					console.log(response);
					FB.api('/me', function(response) {
						console.log('Good to see you, ' + response.name + '.');
						require(['app'],function(App){
							App.router.navigate('', {trigger: true, replace: true});
						});
					});
				} else {
					console.log('User cancelled login or did not fully authorize.');
				}
			});
		});
      
    },
    
    remove: function() {
	    this.$el.html("");
    }

  });

  return HomeView;
  
});