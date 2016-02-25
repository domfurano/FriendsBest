 define([
  'jquery',
  'underscore',
  'backbone',
  'text!templates/profile/back.html',
  'text!templates/profile/menu.html',
], function($, _, Backbone, backHTML, menuHTML){

  var view = Backbone.View.extend({
    el: $(".view"),

    render: function(){
      
      console.log("render profile view")
      
      var backTemplate = _.template( backHTML, {} );
      this.$el.append(backTemplate({name: "Test Name"}));
      
      var menuTemplate = _.template( menuHTML );
      this.$el.append(menuTemplate({id: FB.getAuthResponse().userID}));
 
    },
    
    remove: function() {
	    this.$el.html("");
    }

  });

  return view;
  
});
