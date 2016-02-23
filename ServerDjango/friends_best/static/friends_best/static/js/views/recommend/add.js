define([
  'jquery',
  'underscore',
  'backbone',
  'text!templates/recommend/back.html',
  'text!templates/recommend/form.html',
  'models/recommend',
], function($, _, Backbone, backHTML, formHTML, RecommendModel){

  var RecommendView = Backbone.View.extend({
    el: $(".view"),

    render: function(){
      
      console.log("render new recommendation")
      
      var backTemplate = _.template( backHTML, {} );
      this.$el.append(backTemplate);
      
      var formTemplate = _.template( formHTML );
      this.$el.append(formTemplate({tags: this.tags}));
 
	  $('#tags').tokenfield({delimiter : ' ', createTokensOnBlur: true});
	  
	  $('.submit').click(function() {

		  // Create a Recommend model
		  r = new RecommendModel();
		  
		  // Pull the data
		  r.set({
			  		"detail": $("#description").val(),
			  		"tags": $("#tags").val().toLowerCase().split(" "),
			  		"comments": $("#comments").val()});
		  
		  console.log(r);
		  
		  // Sync the model
		  r.save();
		  
		  // Go back in history
		  parent.history.go(-1);
		  return false;
	  });
 
    },
    
    remove: function() {
	    this.$el.html("");
    }

  });

  return RecommendView;
  
});
