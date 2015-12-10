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

	initialize: function(options) {
		console.log("init ResultsView");
		this.id = options.id;
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
      
		this.model = new QueryModel();
		this.model.set({"id": this.id});
		this.model.fetch({success: function(model, response, options){

			$("#tags").val(model.get("tags").join(" ")).tokenfield({delimiter : ' '});
			

			console.log();
		}});

			// Render the collection
			//solutionsTemplate = _.template(solutionsHTML);
			//that.$el.append(solutionsTemplate({collection: that.collection.toJSON()}));
 
    },
    
    remove: function() {
	    this.$el.html("");
    }

  });

  return ResultsView;
  
});
