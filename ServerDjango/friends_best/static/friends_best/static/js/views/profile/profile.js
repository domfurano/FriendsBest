 define([
  'jquery',
  'underscore',
  'backbone',
  'text!templates/home/menu.html',
  'text!templates/profile/back.html',
  'text!templates/profile/menu.html',
  'models/me',
], function($, _, Backbone, menuHTML, backHTML, profileMenuHTML, meModel){

  var view = Backbone.View.extend({
    el: $(".view"),

    render: function(){
      
      console.log("render profile view")
      
      var menuTemplate = _.template( menuHTML, {} );
      this.$el.html(menuTemplate({id: FB.getAuthResponse().userID}));
      
      // Go to the me/ endpoint to get my name, number of friends and number of recommendations
      
      that = this;
      
      me = new meModel();
      me.fetch({success: function(me, response, options){
            console.log(me);
            var profileMenuTemplate = _.template( profileMenuHTML );
            that.$el.append(profileMenuTemplate(me.toJSON()));
      }});
      
      
      
 
    },
    
    remove: function() {
	    this.$el.html("");
    }

  });

  return view;
  
});
