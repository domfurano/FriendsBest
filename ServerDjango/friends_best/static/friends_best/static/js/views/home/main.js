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
  'text!templates/home/tutorial.html',
  'text!templates/home/menu.html',
  'text!templates/home/deck.html',
  'text!templates/home/info.html',
  'lity'
], function($, _, Backbone, App, Recommend, QueryModel, PromptsCollection, searchHTML, promptHTML, tutorialHTML, menuHTML, deckHTML, infoHTML, lity){

  var HomeView = Backbone.View.extend({
    el: $(".view"),
    visible: true,
    tutorial: false,

    initialize: function(options) {
        if(options.tutorial) {
            this.tutorial = true;
        }
    },

    render: function(){
      
        that = this;
		
		this.$el.removeClass("login");
		
		var deckTemplate = _.template( deckHTML, {} );
		this.$el.append(deckTemplate());
        
        if(!this.tutorial) {
            this.loadPrompts();        
        } else {
            this.loadTutorial();
        }
        
        this.refresh = setInterval(function() {
            $.get( "/fb/api/notification/", function( data ) {
              if(data.notifications == 0) {
                  $("#notification").hide();
              } else {
                  $("#notification").show();
              }
            });
        }, 5000);

		var searchTemplate = _.template( searchHTML, {} );
		this.$el.append(searchTemplate);
		
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
			
			var tags = $('#search-field').val().trim().toLowerCase().split(' ');
			
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
 
    },
    
    remove: function() {
	    this.$el.html("");
	    this.visible = false;
	    clearInterval(this.refresh);
    },
    
    loadTutorial: function() {
        
        that = this;
        
        tutorialTemplate = _.template(tutorialHTML);
        $el = this.$el;
        $el.append(tutorialTemplate());
        
        $("#skip").click(function() {
           $(".tutorialsection").remove();
           window.location = "/";
           that.loadPrompts();
        });

        $("#play").click(function() {
            
            $("#skip").html("start using FriendsBest");
            
            lightbox = lity();
            lightbox('//vimeo.com/163816408');
        });

    },
    
    loadPrompts: function() {
        this.collection = new PromptsCollection();
        //this.collection.on("reset", this.showPrompts, this);
		this.collection.fetch({success: this.showPrompts});
    },
    
    showPrompts: function() {
        
		if(that.visible) {
        		
            prompts = that.collection;
    		
            promptTemplate = _.template(promptHTML);
			
			el = that.$el;
			
			el.find(".promptsection").remove();
			
			prompts.each(function(prompt) {
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
    						prompts.get(ui.helper.attr("id")).destroy({
        						success: function() {
            						if (prompts.length < 1) {
                						setTimeout(function() {
                    						console.log("prompts!");
                    						that.loadPrompts();
                						}, 1000);
                                    }
        						}
    						});
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
