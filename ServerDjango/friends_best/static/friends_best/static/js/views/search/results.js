define([
  'jquery',
  'underscore',
  'backbone',
  'models/query',
  'solutiondetails',
  'views/solution/details',
  'text!templates/search/results/back.html',
  'text!templates/standard/list.html',
  'text!templates/search/results/item.html',
  'text!templates/search/results/postback.html',
], function($, _, Backbone, QueryModel, solutiondetails, SolutionView, backHTML, listHTML, itemHTML, postbackHTML){

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
    		itemTemplate = _.template(itemHTML);
    		_.each(solutions, function(solution, index) {

    			solution.id = index;
    			var item = $(itemTemplate(solution));
				this.$list.append(item);
				item.find(".thing").solutiondetails(solution, {context: this.$list});

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
