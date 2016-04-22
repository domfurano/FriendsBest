define([
  'jquery',
  'underscore',
  'backbone',
  'app',
  'text!templates/home/login.html',
  'fb'
], function($, _, Backbone, App, loginHTML){

  var HomeView = Backbone.View.extend({
    el: $(".view"),

    render: function(){
        
        console.log("rendering login view");
      
		var loginTemplate = _.template( loginHTML, {} );
		this.$el.html(loginTemplate);
		this.$el.addClass("login");
		
		$(".fb-login-button").click(function() {
			FB.login(function(response) {
				// The response contains the token that needs to be sent to the server
				if (response.authResponse) {
					console.log(response);
					FB.api('/me', function(response) {
						console.log('Good to see you, ' + response.name + '.');
						require(['app'],function(App){
							App.router.navigate('', {trigger: true, replace: true});
							window.location = "/#loggedin";
							window.location.reload(true);
						});
					});
				} else {
					console.log('User cancelled login or did not fully authorize.');
				}
			}, {scope: 'public_profile,email,user_friends'});
		});
      
    },
    
    remove: function() {
	    this.$el.html("");
    }

  });

  return HomeView;
  
});
