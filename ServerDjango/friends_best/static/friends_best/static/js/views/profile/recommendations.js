 define([
  'jquery',
  'underscore',
  'backbone',
  'solutiondetails',
  'text!templates/home/menu.html',
  'text!templates/standard/back.html',
  'text!templates/standard/list.html',
  'text!templates/profile/recommendation.html',
  'collections/recommendations',
], function($, _, Backbone, solutiondetails, menuHTML, backHTML, listHTML, itemHTML, RecommendationsCollection){

  var view = Backbone.View.extend({
    el: $(".view"),
    visible: true,

	initialize: function() {
		console.log("initialize");
		this.visible = true;
		this.collection = new RecommendationsCollection();
		//this.collection.on("update", this.list, this);
		this.collection.fetch({ success: this.list });
	},

    render: function(){
	    
	    that = this;
	    
	    // Back
	    var backTemplate = _.template( backHTML );
		this.$el.append(backTemplate({
			color: "#ffffff",
			background: "#59c939",
			title: "Your Recommendations"
		}));
	    
	    // List
		var listTemplate = _.template( listHTML );
		this.$el.append(listTemplate);
		this.$list = $(".listcontainer");
    },
    
    list: function() {

	    if(that.visible) {		    
		    // Clear the list
			that.$list.html("");
			
			// Add elements to the list
		    var itemTemplate = _.template( itemHTML );
		    that.collection.each(function(i, index) {
			    var item = $(itemTemplate(i.toJSON()));
			    that.$list.prepend(item);
			    item.find(".thing").solutiondetails(i.toJSON(), {context: that.$list.parent()});
		    });
		    
		    // Activate delete buttons
		    that.$list.find(".delete").one("click", function() {
    		    id = $(this).attr("id");
    		    that.trash(id, $(this));
		    }) 
		    
	    }

	},
    
    trash: function(id, $button) {
        // Convert to X
        $button.find("i").toggleClass("fa-trash-o fa-times")
        that = this;
        $button.one("click", function() {
            // Delete model
            that.collection.get(id).destroy();
            // Delete UI
            $("#rec"+id).remove();
        });
    },
    
    remove: function() {
	    this.$el.html("");
	    this.visible = false;
    }

  });

  return view;
  
});
