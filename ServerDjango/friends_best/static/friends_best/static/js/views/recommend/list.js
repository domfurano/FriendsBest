define([
  'jquery',
  'underscore',
  'backbone',
  'collections/recommendations',
  'text!templates/recommendations/back.html',
  'text!templates/recommendations/list.html',
], function($, _, Backbone, RecommendationsCollection, backHTML, listHTML){

  var view = Backbone.View.extend({
    el: $(".view"),

    render: function(){
		
		var backTemplate = _.template( backHTML, {} );
		this.$el.append(backTemplate);
		
		var listTemplate = _.template( listHTML );
		this.$el.append(formTemplate({tags: this.tags}));
		
		this.collection = new RecommendationsCollection();
		this.collection.fetch({success: function(collection, response, options){
			listTemplate = _.template(listHTML);
			that.$el.append(listTemplate({collection: collection.toJSON()}));
		}});
 
    },
    
    remove: function() {
	    this.$el.html("");
    }

  });

  return view;
  
});
