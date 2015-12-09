define([
  'jquery',
  'underscore',
  'backbone',
  'collections/queries',
  'text!templates/search/history/back.html',
  'text!templates/search/history/items.html',
], function($, _, Backbone, QueriesCollection, backHTML, itemsHTML){

require.config({
    urlArgs: "bust=" + (new Date()).getTime()
});

  var HistoryView = Backbone.View.extend({
    el: $(".view"),

	initialize: function() {
		console.log("init HistoryView")
	},

    render: function(){
      
		that = this;
		
		var backTemplate = _.template( backHTML, {} );
		this.$el.append(backTemplate);
		$(".back-button").click(function() {
			console.log("going back");
			parent.history.go(-1);
			return false;
		});
      
		this.collection = new QueriesCollection();
		this.collection.fetch({success: function(collection, response, options){
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
