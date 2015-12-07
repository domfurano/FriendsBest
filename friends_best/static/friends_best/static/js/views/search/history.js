define([
  'jquery',
  'underscore',
  'backbone',
  'collections/queries',
  'text!templates/search/back.html',
  'text!templates/search/item.html',
], function($, _, Backbone, QueriesCollection, backHTML, itemHTML){

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
      
      this.collection = new QueriesCollection();
      
      this.collection.fetch({success: function(collection, response, options){
			// Render the collection
			itemTemplate = _.template(itemHTML);
			that.$el.append(itemTemplate({collection: that.collection.toJSON()}));
      }});
      
      var backTemplate = _.template( backHTML, {} );
      this.$el.append(backTemplate);
      
      $(".back-button").click(function() {
	      console.log("going back");
	      parent.history.go(-1);
	      return false;
      });
 
    },
    
    remove: function() {
	    this.$el.html("");
    }

  });

  return HistoryView;
  
});
