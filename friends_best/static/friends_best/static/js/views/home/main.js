define([
  'jquery',
  'underscore',
  'backbone',
  'app',
  'views/recommend/add',
  'models/query',
  'text!templates/home/search.html',
  'text!templates/home/prompt.html',
  'text!templates/home/menu.html'
], function($, _, Backbone, App, Recommend, QueryModel, searchHTML, promptHTML, menuHTML){

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
      
		$('#search-field').tokenfield({delimiter : ' ', inputType: 'search'});
		
		$('#search-field-tokenfield').keypress(function (e) {
		  if (e.which == 13) {
		    $('form#query').submit();
		    return false;
		  }
		});
		
		$('form#query').submit(function() {
			// Get tags
			var tags = $('#search-field').val().toLowerCase().split(' ');
			// create query
			var query = new QueryModel({user: 2, tags: tags});
			// save query
			query.save({success: function(model, response, options) {
				var id = model.get("id");
				// route to id
				console.log(id);
			}});
			return false;
		});
		
		// Prompts
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
							r = new Recommend()
							r.tags = ui.helper.children(".topic").html();
							App.router.navigate('recommend');
							App.router.render(r);
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
