define([
  'jquery',
  'underscore',
  'backbone',
  'text!templates/recommend/back.html',
  'text!templates/recommend/form.html',
], function($, _, Backbone, backHTML, formHTML){

  var HomeView = Backbone.View.extend({
    el: $(".view"),

    render: function(){
      
      console.log("render new recommendation")
      
      var backTemplate = _.template( backHTML, {} );
      this.$el.append(backTemplate);
      
      var formTemplate = _.template( formHTML, {} );
      this.$el.append(formTemplate);
 
    },
    
    remove: function() {
	    this.$el.html("");
    }

  });

  return HomeView;
  
});
