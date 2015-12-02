define([
  'jquery',
  'underscore',
  'backbone',
  'app',
  'text!templates/home/search.html',
  'text!templates/home/prompt.html',
  'text!templates/home/menu.html'
], function($, _, Backbone, App, searchHTML, promptHTML, menuHTML){

  var HomeView = Backbone.View.extend({
    el: $(".view"),

    render: function(){
      
		var menuTemplate = _.template( menuHTML, {} );
		this.$el.html(menuTemplate);
		
		var promptTemplate = _.template(promptHTML);
		
		prompts = 	_.shuffle([
						{item : "Yoga Pants", user: "Paul Hanson"},
						{item : "Fast Food", user: "Ray Phillips"},
						{item : "Hoverboards", user: "Dominic Furano"},
						{item : "Vacuums", user: "Umair Naveed"},
						{item : "Reverse Engineering", user: "Jim de St. Germain"},
						{item : "Guy Birthday Present"},
						{item : "UofU CS Elective"},
						{item : "Snowshoes"},
						{item : "Italian Restaurant"},
						{item : "Science Fiction Novel"},
					]);
		
		_.each(prompts, function(prompt) {
			this.$el.append(promptTemplate(prompt));
		}, this);
		
		var searchTemplate = _.template( searchHTML, {} );
		this.$el.append(searchTemplate);
      
		$('#search-field').tokenfield({delimiter : ' '});
		
		$('.swipable').each( function(index, item) {
			d = Math.random() * 3 - 1.5;
			$(item).css({'transform': 'rotate('+d+'deg)'});
		});
		
		
		distance = 30;
		$('.swipable').draggable({
			revert: function(ui, ui2) {
				if($(this).position().left < -distance || $(this).position().left > distance) return false;
				else return true;
			},
			axis: "x",
			scroll: false,
			stop: function(event, ui) {	
				if(ui.position.left < -distance) {
					ui.helper.animate({left: "-=600"}, 200, function() {
						ui.helper.parent().remove();
					});
				} else if(ui.position.left > distance) {
					ui.helper.animate({left: "+=600"}, 200, function() {
						require(['app'],function(App){
							App.router.navigate('recommend', {trigger: true});
						});
					});
				}
			}
		});
 
    },
    
    remove: function() {
	    this.$el.html("");
    }

  });

  return HomeView;
  
});
