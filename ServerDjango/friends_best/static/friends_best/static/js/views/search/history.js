define([
  'jquery',
  'underscore',
  'backbone',
  'collections/queries',
  'text!templates/standard/back.html',
  'text!templates/standard/list.html',
  'text!templates/search/history/item.html',
], function($, _, Backbone, QueriesCollection, backHTML, listHTML, itemHTML){

  var HistoryView = Backbone.View.extend({
    el: $(".view"),

	initialize: function() {
        this.visible = true;
        this.collection = new QueriesCollection();
        this.collection.on("sync", this.list, this);
		this.collection.fetch();
	},

    render: function(){
		
		// Back
		var backTemplate = _.template( backHTML );
		this.$el.append(backTemplate({
			color: "#ffffff",
			background: "#abb4ba",
			title: "Search History"
		}));
		
		// List
		listTemplate = _.template(listHTML);
		this.$el.append(listTemplate());
		this.$list = $(".listcontainer");
 
    },
    
    list: function() {
        if(this.visible) {
            
            // Empty the list
    		this.$list.html("");
            
            // Sort the collection
            this.collection.sort();

            // Add elements to the list
		    var itemTemplate = _.template( itemHTML );
		    this.collection.each(function(i, index) {
    		    item = i.toJSON();
    		    if(item.notifications) {
        		    this.$list.prepend(itemTemplate(item));    
    		    } else {
        		    this.$list.append(itemTemplate(item));    
    		    }
			    
		    }, this);
		    
		    // Make list clickable
		    $(".line").click(function() {
    			id = $(this).attr("id");
    			require(['app'],function(App){
    			    App.router.navigate('search/' + id, true);
                });
    		});
		    
		    // Show text if there was nothing visible...
    		if(this.collection.length == 0) {
    			this.$list.append("<div class='container'><div class='row hint'>No previous searches</div></div>");
    		}
        }  
    },
    
    remove: function() {
	    this.$el.html("");
    }

  });

  return HistoryView;
  
});
