 define([
  'jquery',
  'underscore',
  'backbone',
  'text!templates/home/menu.html',
  'text!templates/profile/back.html',
  'text!templates/profile/menu.html',
  'text!templates/profile/recommendation.html',
  'models/me',
  'collections/recommendations',
], function($, _, Backbone, menuHTML, backHTML, profileMenuHTML, recommendationHTML, meModel, RecommendationsCollection){

  var view = Backbone.View.extend({
    el: $(".view"),

	initialize: function(options) {
		this.page = options.page;
		console.log(typeof this.page);
	},

    render: function(){
		
		switch(this.page) {
			case "recommendations":
				this.recommendations();
				break;
			default:
				this.main();
		}
 
    },
    
    main: function() {
	    that = this;
		me = new meModel();
		me.fetch({success: function(me, response, options){
		    var profileMenuTemplate = _.template( profileMenuHTML );
		    that.$el.append(profileMenuTemplate(me.toJSON()));
		    image = FB.image.clone().width(150).height(150).addClass("img-circle");
			that.$el.find(".photo").append(image);
		}});
    },
    
    recommendations: function() {
	    that = this;
		recs = new RecommendationsCollection();
		recs.fetch({success: function(collection, response, options){
			
			// Create the list continer
			list = $("<section>").addClass("list scrollable");
			
			// Add elements to the list
		    var itemTemplate = _.template( recommendationHTML );
		    collection.each(function(rec, index) {
			    list.append(itemTemplate(rec.toJSON()));
		    });
		    
		    // Add list to view
		    that.$el.append(list);
		    
		}});
    },
    
    remove: function() {
	    this.$el.html("");
    }

  });

  return view;
  
});
