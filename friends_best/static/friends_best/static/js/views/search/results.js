define([
  'jquery',
  'underscore',
  'backbone',
  'models/query',
  'text!templates/search/results/back.html',
  'text!templates/search/results/items.html',
], function($, _, Backbone, QueryModel, backHTML, itemsHTML){

  var ResultsView = Backbone.View.extend({
    el: $(".view"),

	initialize: function() {
		console.log("init ResultsView")
	},

    render: function() {
      
		that = this;
		
		var backTemplate = _.template( backHTML, {} );
		this.$el.append(backTemplate);
		$(".back-button").click(function() {
			console.log("going back");
			parent.history.go(-1);
			return false;
		});
		
		itemsTemplate = _.template(itemsHTML);
		that.$el.append(itemsTemplate());
/*
      
		this.collection = new ResultsCollection();
		this.collection.fetch({success: function(collection, response, options){
			// Render the collection
			solutionsTemplate = _.template(solutionsHTML);
			that.$el.append(solutionsTemplate({collection: that.collection.toJSON()}));
		}});
*/
 
    },
    
    remove: function() {
	    this.$el.html("");
    }

  });

  return ResultsView;
  
});
