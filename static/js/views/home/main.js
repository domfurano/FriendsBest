define([
  'jquery',
  'underscore',
  'backbone',
  'text!templates/home/search.html',
  'text!templates/home/prompt.html',
  'text!templates/home/menu.html'
], function($, _, Backbone, searchHTML, promptHTML, menuHTML){

  var HomeView = Backbone.View.extend({
    el: $(".view"),

    render: function(){
      
		var menuTemplate = _.template( menuHTML, {} );
		this.$el.html(menuTemplate);
		
		var promptTemplate = _.template(promptHTML);
		this.$el.append(promptTemplate({item : "Fast Food", user: "Ray Phillips"}));
		this.$el.append(promptTemplate({item : "Yoga Pants", user: "Paul Hanson"}));
		
		var searchTemplate = _.template( searchHTML, {} );
		this.$el.append(searchTemplate);
      
		$('#search-field').tokenfield({delimiter : ' '});
		$('.prompt').draggable({
			revert: true,
			revertDuration: 200,
			axis: "x",
			scroll: false
		});
 
    },
    
    remove: function() {
	    this.$el.html("");
    }

  });

  return HomeView;
  
});
