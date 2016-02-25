 define([
  'jquery',
  'underscore',
  'backbone',
  'text!templates/home/menu.html',
  'text!templates/profile/back.html',
  'text!templates/profile/menu.html',
], function($, _, Backbone, menuHTML, backHTML, profileMenuHTML){

  var view = Backbone.View.extend({
    el: $(".view"),

    render: function(){
      
      console.log("render profile view")
      
      var menuTemplate = _.template( menuHTML, {} );
      this.$el.html(menuTemplate({id: FB.getAuthResponse().userID}));
      
      var profileMenuTemplate = _.template( profileMenuHTML );
      this.$el.append(profileMenuTemplate({id: FB.getAuthResponse().userID, name: ""}));
      
 
    },
    
    remove: function() {
	    this.$el.html("");
    }

  });

  return view;
  
});
