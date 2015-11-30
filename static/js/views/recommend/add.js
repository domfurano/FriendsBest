define([
  'jquery',
  'underscore',
  'backbone',
  'text!templates/recommend/back.html',
], function($, _, Backbone, backHTML){

  var HomeView = Backbone.View.extend({
    el: $(".view"),

    render: function(){
      
      console.log("render search history")
      
      var backTemplate = _.template( backHTML, {} );
      this.$el.append(backTemplate);
 
    },
    
    remove: function() {
	    this.$el.html("");
    }

  });

  return HomeView;
  
});
