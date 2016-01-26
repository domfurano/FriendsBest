define([
  'jquery',
  'underscore',
  'backbone',
  'models/query',
  'text!templates/search/results/solution/back.html',
  'text!templates/search/results/solution/comments.html',
  'text!templates/search/results/solution/comment.html',
], function($, _, Backbone, QueryModel, backHTML, commentsHTML, commentHTML){

  var SolutionView = Backbone.View.extend({
    el: $(".view"),

	initialize: function(options) {
		this.solution = options.solution;
	},

    render: function() {
      
		that = this;
		
		var backTemplate = _.template(backHTML);
		this.$el.append(backTemplate(this.solution));
		$(".back-button").click(function() {
			console.log("going back");
			parent.history.go(-1);
			return false;
		});
		
		commentsTemplate = _.template(commentsHTML);
		that.$el.append(commentsTemplate(this.solution));
		

		
		// Empty the list
		var list = that.$el.find(".listcontainer");
		list.html("");
		
		commentTemplate = _.template(commentHTML);
		_.each(this.solution.recommendation, function(recommendation, index) {
			r = { name: recommendation.name.trim(),
				  comment: recommendation.comment.split("\n").join("<br>")};
			list.append(commentTemplate(r));
		});

      
    },
    
    remove: function() {
	    this.$el.html("");
    }

  });

  return SolutionView;
  
});
