define([
  'jquery',
  'underscore',
  'backbone',
  'models/query',
  'views/solution/details',
  'text!templates/search/results/back.html',
  'text!templates/search/results/items.html',
  'text!templates/search/results/item.html',
], function($, _, Backbone, QueryModel, SolutionView, backHTML, itemsHTML, itemHTML){

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
		
		var list = that.$el.find(".listcontainer");
      
		var id = this.id;
      
		this.model = new QueryModel();
		this.model.set({"id": this.id});
		this.model.fetch({success: function(model, response, options){

			// Load tags into the search field
			$("#tags").val(model.get("tags").join(" ")).tokenfield({delimiter : ' '});
			
			// Empty the list
			list.html("");
			
			var solutions = []
			itemTemplate = _.template(itemHTML);
			_.each(model.get("solutions"), function(solution, index) {
				s = {
								id: index,
								name: solution.detail.split("\n")[0].trim(),
								longname: solution.detail.split("\n").join("<br>"),
								recommendations: solution.recommendations
							};
				solutions.push(s);
				list.append(itemTemplate(s));
			});
			
			$(".solution").click(function() {
				index = $(this).attr("id");
				
				// Create a view with the solution at the index.
				solution = solutions[index];
				
				require(['app'],function(App){
							App.router.render(new SolutionView({solution: solution}));
							App.router.navigate('search/' + id + '/' + index);
						});
				
			});
			
			if(model.get("solutions").length == 0) {
				list.append("<div class='container text'>No results</div>")
			}

		}});
 
    },
    
    remove: function() {
	    this.$el.html("");
    }

  });

  return ResultsView;
  
});
