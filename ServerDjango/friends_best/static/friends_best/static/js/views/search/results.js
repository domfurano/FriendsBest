define([
  'jquery',
  'underscore',
  'backbone',
  'models/query',
  'placedetails',
  'views/solution/details',
  'text!templates/search/results/back.html',
  'text!templates/standard/list.html',
  'text!templates/search/results/item-text.html',
  'text!templates/search/results/item-url.html',
  'text!templates/search/results/item-place.html',
  'text!templates/standard/place.html',
  'text!templates/search/results/postback.html',
  'async!//maps.google.com/maps/api/js?sensor=false&libraries=places',
], function($, _, Backbone, QueryModel, placedetails, SolutionView, backHTML, listHTML, itemTextHTML, itemURLHTML, itemPlaceHTML, placeHTML, postbackHTML){

  var ResultsView = Backbone.View.extend({
    el: $(".view"),

	initialize: function(options) {
		this.id = options.id;
        this.visible = true;
		this.model = new QueryModel();
		this.model.set({"id": this.id});
		this.model.on("sync", this.list, this);
		this.model.fetch();
	},

    render: function() {
		
		// Back
		var backTemplate = _.template( backHTML, {} );
		this.$el.append(backTemplate());
		$(".back-button").click(function() {
			console.log("going back");
			parent.history.go(-1);
			return false;
		});
		
		// List
		listTemplate = _.template(listHTML);
		this.$el.append(listTemplate());
		this.$list = $(".listcontainer");
		
        // Delete button
        model = this.model;
        $(".delete").click(function() {
            if(confirm("Do you really want to delete this search?")) {
                model.destroy();
                parent.history.go(-1);
            }
        });
 
    },
    
    list: function() {
        if(this.visible) {	
            
            // Load tags into the search field
    		tags = $(".tags");
    		_.each(this.model.get("tagstring").split(" "), function(tag) {
    		    tags.append($("<span>").html(tag));
            }, this);
            
    		// Empty the list
    		this.$list.html("");
    		
    		// Populate the list
    		var solutions = this.model.get("solutions");
    		itemTextTemplate = _.template(itemTextHTML);
    		itemURLTemplate = _.template(itemURLHTML);
    		itemPlaceTemplate = _.template(itemPlaceHTML);
    		placeTemplate = _.template(placeHTML);
    		_.each(solutions, function(solution, index) {
        		
        		switch(solution.type) {
	        		case 'url':
	        			solution.id = index;
						solution.name = solution.detail.trim();
						this.$list.append(itemURLTemplate(solution));
						break;
	        		case 'place':
	        			solution.id = index;
						this.$list.append(itemPlaceTemplate(solution));
						$("#"+index).find(".place").placedetails({placeid: solution.detail});
						break;
	        		case 'text':
	        		default:
	        			solution.id = index;
						solution.name = solution.detail.split("\n")[0].trim();
						solution.longname = solution.detail.split("\n").join("<br>");
						this.$list.append(itemTextTemplate(solution));
        		}

    		}, this);
    		
    		// Make the list clickable
    		id = this.id;
    		$(".solution").click(function() {
    			index = $(this).attr("id");
    			
    			// Create a view with the solution at the index.
    			solution = solutions[index];
    			console.log(solution);
    			
    			require(['app'],function(App){
    				App.router.render(new SolutionView({solution: solution}));
    				App.router.navigate('search/' + id + '/' + index);
    			});
    			
    		});
    		
    		// Show text if there was nothing visible...
    		if(model.get("solutions").length == 0) {
    			this.$list.append("<div class='container'><div class='row hint'>No results</div></div>")
    		}
    		
    		// Add the postback button
    		postbackTemplate = _.template(postbackHTML);
            this.$list.append(postbackTemplate({id: id}));
            $(".postback").click(function() {
                url = "https://www.friendsbest.net/fb/link/" + id + "/";
                FB.ui({
                    method: 'share',
                    href: url,
                }, function(response){});
            });
		}
    },
    
    remove: function() {
	    this.$el.html("");
    }

  });

  return ResultsView;
  
});
