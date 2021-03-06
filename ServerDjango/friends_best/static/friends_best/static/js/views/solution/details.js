define([
  'jquery',
  'underscore',
  'backbone',
  'models/query',
  'models/notification',
  'text!templates/search/results/solution/back.html',
  'text!templates/search/results/solution/comments.html',
  'text!templates/search/results/solution/friendcomment.html',
  'text!templates/search/results/solution/comment.html',
], function($, _, Backbone, QueryModel, NotificationModel, backHTML, commentsHTML, friendcommentHTML, commentHTML){

  var SolutionView = Backbone.View.extend({
    el: $(".view"),

	initialize: function(options) {
		this.solution = options.solution;
	},

    render: function() {
      
		that = this;
		
		var backTemplate = _.template(backHTML);
		var back = this.$el.append(backTemplate(this.solution));
		back.find(".details").solutiondetails(solution);	
		
		$(".back-button").click(function() {
			console.log("going back");
			parent.history.go(-1);
			return false;
		});
		
		$(".details").on("click", ".url, .place", function() {
    		url = $(this).attr("data-url");
    		if(url) {
        		window.open(url, "_blank");
    		}
		});
		
		commentsTemplate = _.template(commentsHTML);
		that.$el.append(commentsTemplate(this.solution));
		
		// Empty the list
		var list = that.$el.find(".listcontainer");
		list.html("");
		
		commentTemplate = _.template(commentHTML);
        friendcommentTemplate = _.template(friendcommentHTML);
        
        var legit = 0;
        
		_.each(this.solution.recommendations, function(recommendation, index) {
    		console.log(recommendation);
    		
    		r = { comment: recommendation.comment.split("\n").join("<br>") };
            // Some recommendations wont have a user (if they're not from a friend)
    		if(_.has(recommendation, 'user')) {
        		r.name = recommendation.user.name.trim();
                r.id = recommendation.user.id;
                comment = friendcommentTemplate(r);
    		} else if(recommendation.comment != "") {
        	    comment = commentTemplate(r);
    		} else {
        		comment = commentTemplate({comment: "<i>Anonymous Recommendation</i>"});
    		}
    		
    		comment = $(comment);
    		
            // Remove any notifications
    		if(recommendation.isNew) {
        		// Highight new comments
        		comment.addClass("new");
        		
        		// Remove notification
        		id = recommendation.id
        		n = new NotificationModel({id: id})
        		n.destroy();
        		console.log("Destroyed notification for " + id)
    		}
    		
    		list.append(comment);
    				
		});
      
    },
    
    remove: function() {
	    this.$el.html("");
    }

  });

  return SolutionView;
  
});
