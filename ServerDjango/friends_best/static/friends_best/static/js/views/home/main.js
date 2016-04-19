define([
  'jquery',
  'underscore',
  'backbone',
  'app',
  'views/recommend/recommend',
  'models/query',
  'collections/prompts',
  'text!templates/home/search.html',
  'text!templates/home/prompt.html',
  'text!templates/home/menu.html',
  'text!templates/home/deck.html',
  'text!templates/home/info.html',
], function($, _, Backbone, App, Recommend, QueryModel, PromptsCollection, searchHTML, promptHTML, menuHTML, deckHTML, infoHTML){

  var HomeView = Backbone.View.extend({
    el: $(".view"),
    visible: true,

    render: function(){
      
        that = this;
		
		var deckTemplate = _.template( deckHTML, {} );
		this.$el.append(deckTemplate());
        
        this.loadPrompts();        
        
        this.refresh = setInterval(function() {
            if (that.collection.length < 1) {
                that.loadPrompts();
            }
        }, 1000);

		var searchTemplate = _.template( searchHTML, {} );
		this.$el.append(searchTemplate);
      
		//$('#search-field').tokenfield({delimiter : ' ', inputType: 'search', createTokensOnBlur: true});
		
		$('#search-field').keypress(function (e) {
		  if (e.which == 13) {
            $('#search-field').attr("disabled", "disabled");
		    $('#search-field').submit();
		    return false;
		  }
		});
		
		$(".submit").click(function() {
			$('form#query').submit();
		    return false;
		});
		
		$('form#query').submit(function() {
			
			var tags = $('#search-field').val().toLowerCase().split(' ');
			
			if(tags.length == 0) return false;
			if(tags.length == 1 && tags[0] == "") return false;
			
			tags = _.map(tags, String.toLowerCase);
			
			// create query
			var query = new QueryModel({tags: tags});
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
		
		// Logout (TEMP)
		$("#facebookCircleIcon").click(function() {

/*
			FB.logout(function(response) {
 				document.cookie = 'fblo_1519942364964737=;expires=Thu, 01 Jan 1970 00:00:01 GMT;';
 				location.reload();
			});
*/

            // Load profile menu instead via profile route
            
			
		});
 
    },
    
    remove: function() {
	    this.$el.html("");
	    this.visible = false;
	    clearInterval(this.refresh);
    },
    
    loadPrompts: function() {
        this.collection = new PromptsCollection();
        this.collection.on("update", this.showPrompts, this);
		this.collection.fetch();
    },
    
    showPrompts: function() {
        
		if(this.visible) {
        		
            prompts = this.collection;
    		
            promptTemplate = _.template(promptHTML);
			
			el = that.$el;
			
			el.find(".promptsection").remove();
			
			prompts.each(function(prompt) {
				if(prompt.get("tagstring") == "") {
					console.log("suppressed a blank prompt");
					prompt.destroy();
				}
    			promptcard = promptTemplate(prompt.toJSON());
    			el.append(promptcard);
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
        			// Left: delete prompt
    				if(ui.position.left < -distance) {
    					ui.helper.animate({left: "-=600"}, 200, function() {
    						ui.helper.parent().remove();
    						prompts.get(ui.helper.attr("id")).destroy();
    					});
    				// Right: recommend
    				} else if(ui.position.left > distance) {
    					ui.helper.animate({left: "+=600"}, 200, function() {
        					//prompts.get(ui.helper.attr("id")).destroy();
    						require(['app'],function(App){
    							r = new Recommend({
                                    model: prompts.get(ui.helper.attr("id"))	
    							});
    							//r.tags = ui.helper.children(".topic").html();
    							App.router.navigate('recommend');
    							App.router.render(r);
    						});
    					});
    				}
    			}
    		});
        }
    }

  });

  return HomeView;
  
});
