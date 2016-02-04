define([
  'jquery',
  'underscore',
  'backbone',
  'app',
  'views/recommend/add',
  'views/search/results',
  'models/query',
  'text!templates/home/search.html',
  'text!templates/home/prompt.html',
  'text!templates/home/menu.html'
], function($, _, Backbone, App, Recommend, ResultsView, QueryModel, searchHTML, promptHTML, menuHTML){

  var HomeView = Backbone.View.extend({
    el: $(".view"),

    render: function(){
      
		var menuTemplate = _.template( menuHTML, {} );
		this.$el.html(menuTemplate);
		
		var promptTemplate = _.template(promptHTML);
		
		prompts = 	_.shuffle([
						{item : "Wireless Mouse", user: "Jim de St. Germain"},
						{item : "Gym", user: "Dominic Furano"},
						{item : "Coffee Shop", user: "Ray Phillips"},
						{item : "Sushi Restaurant", user: "Umair Naveed"},
						{item : "Fantasy Novel", user: "Paul Hanson"},
					]);
		
		_.each(prompts, function(prompt) {
			this.$el.append(promptTemplate(prompt));
		}, this);
		
		var searchTemplate = _.template( searchHTML, {} );
		this.$el.append(searchTemplate);
      
		$('#search-field').tokenfield({delimiter : ' ', inputType: 'search', createTokensOnBlur: true});
		
		$('#search-field-tokenfield').keypress(function (e) {
		  if (e.which == 13) {
		    $('form#query').submit();
		    return false;
		  }
		});
		
		$(".submit").click(function() {
			$('form#query').submit();
		    return false;
		});
		
		$('form#query').submit(function() {
			
			var tags = $('#search-field').tokenfield('getTokensList').toLowerCase().split(' ');
			
			if(tags.length == 0) return false;
			if(tags.length == 1 && tags[0] == "") return false;
			
			tags = _.map(tags, String.toLowerCase);
			
			// create query
			var query = new QueryModel({user: 2, tags: tags});
			// save query
			query.save(null, {
				success: function(model, response, options) {
					var id = model.get("id");
					var number = model.get("solutions").length;
					// route to id
					console.log("we have a new query, " + id + ", and got " + number + " solutions.");
					require(['app'],function(App){
						App.router.navigate('search/'+id, {trigger: true});
					});
				},
				error: function() {
					console.log("error saving model");
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
		
		// Logout (TEMP)
		$("#facebookCircleIcon").click(function() {

			FB.logout(function(response) {
 				document.cookie = 'fblo_1519942364964737=;expires=Thu, 01 Jan 1970 00:00:01 GMT;';
 				location.reload();
			});
			
		});
 
    },
    
    remove: function() {
	    this.$el.html("");
    }

  });

  return HomeView;
  
});
