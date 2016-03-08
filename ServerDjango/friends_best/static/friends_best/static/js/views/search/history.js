define([
  'jquery',
  'underscore',
  'backbone',
  'collections/queries',
  'text!templates/standard/back.html',
  'text!templates/search/history/items.html',
], function($, _, Backbone, QueriesCollection, backHTML, itemsHTML){

  var HistoryView = Backbone.View.extend({
    el: $(".view"),

	initialize: function() {
		console.log("init HistoryView")
	},

    render: function(){
      
		that = this;
		
		var backTemplate = _.template( backHTML );
		this.$el.append(backTemplate({
			color: "#ffffff",
			background: "#abb4ba",
			title: "Search History"
		}));
      
		this.collection = new QueriesCollection();
		this.collection.fetch({success: function(collection, response, options){
    		
    		collection.sort();
    		
			// Render the collection
			itemsTemplate = _.template(itemsHTML);
			that.$el.append(itemsTemplate({collection: that.collection.toJSON()}));
		}});
 
    },
    
    remove: function() {
	    this.$el.html("");
    }

  });

  return HistoryView;
  
});
