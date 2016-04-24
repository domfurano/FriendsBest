define([
  'jquery',
  'underscore',
  'backbone',
  'models/recommend',
  'placefinder',
  'solutiondetails',
  'text!templates/standard/cancel.html',
  'text!templates/standard/cancelsubmit.html',
  'text!templates/recommend/picker.html',
  'text!templates/recommend/place.html',
  'text!templates/recommend/url.html',
  'text!templates/recommend/text.html',
  'text!templates/recommend/comments.html',
], function($, _, Backbone, RecommendModel, placefinder, solutiondetails, cancelHTML, cancelsubmitHTML, pickerHTML, placeHTML, urlHTML, textHTML, commentsHTML){

    var getLocation = function(href) {
        
        if(href.indexOf("://") == -1) {
            if(href.indexOf("//") > -1) {
                href = "http:" + href;
            } else {
                href = "http://" + href;
            }    
        }
        
        var l = document.createElement("a");
        l.href = href;
        return l;
    };

  var view = Backbone.View.extend({
    el: $(".view"),
    
    initialize: function() {
        if ("model" in this) {
            this.prompt = this.model;
        }
        // Create a recommendation model
        this.recommendation = new RecommendModel();
    },
    
    render: function(){

        this.$el.empty();
        
        console.log(this.recommendation);
        
        // Load correct view based on model
        if(!this.recommendation.has("type")) {
            this.picker();
        } else if(!this.recommendation.has("detail")) {
            (this[this.recommendation.get("type")])();
        } else {
            this.comments();
        }
 
    },
    
    // The first step in making a recommendation, picking the type
    picker: function() {
        
        // Cancel UI
        var cancelTemplate = _.template( cancelHTML );
        this.$el.append(cancelTemplate({
            color: "#ffffff",
            background: "#59c939",
            title: "New Recommendation",
        }));
        
        // Type picker
        var pickerTemplate = _.template( pickerHTML );
        this.$el.append(pickerTemplate());
        
        this.pickerButton("place");
        this.pickerButton("url");
        this.pickerButton("text");
        
    },
    
    pickerButton: function(type) {
        that = this;
        $("#"+type).click(function() {
            that.recommendation.set("type", type);
            that.render();
        });
    },
    
    place: function() {
        // Cancel UI
        var cancelTemplate = _.template( cancelHTML );
        this.$el.append(cancelTemplate({
            color: "#ffffff",
            background: "#59c939",
            title: "New Recommendation"
        }));
        
        // Place picker
        var template = _.template( placeHTML );
        this.$el.append(template());
        
        that = this;
        $.fn.placefinder({
		  map: $('#map'),
		  input: $('#search'),
		  result: $('#placebox'),
		  pick: function(name, address, placeid) {
			  that.recommendation.set("detail", placeid);
			  that.recommendation.set("name", name);
			  that.recommendation.set("address", address);
			  that.render();
		  }
		});
        
    },
    
    url: function() {
        // Cancel UI
        var cancelTemplate = _.template( cancelHTML );
        this.$el.append(cancelTemplate({
            color: "#ffffff",
            background: "#59c939",
            title: "New Recommendation"
        }));
        
        // Text entry
        var template = _.template( urlHTML );
        this.$el.append(template());
        
        $("#detail").focus();
        
        that = this;
        $("form").submit(function() {
            // Get url
            text = $("#detail").val();
            if(text != "") {
                that.recommendation.set("detail", getLocation(text));
                that.recommendation.set("host", getLocation(text).hostname);
                that.render();
            }
            return false;
        });
        
        $('button').click(function() {
            $("form").submit();
            return false;
        });
    },
    
    text: function() {
        // Cancel UI
        var cancelTemplate = _.template( cancelHTML );
        this.$el.append(cancelTemplate({
            color: "#ffffff",
            background: "#59c939",
            title: "New Recommendation"
        }));
        
        // Text entry
        var template = _.template( textHTML );
        this.$el.append(template());
        
        $("#detail").focus();
        
        that = this;
        $("form").submit(function() {
            // Get text
            text = $("#detail").val();
            if(text != "") {
                that.recommendation.set("detail", text);
                that.render();
            }
            return false;
        });
        
        $('button').click(function() {
            $("form").submit();
            return false;
        });
    },
    
    comments: function() {
        // If prompt was specified, show tags
        //if (typeof this.prompt != 'undefined') {
        //    tags = this.prompt.get("tagstring");
        //}
        
        // Cancel UI
        var cancelTemplate = _.template( cancelsubmitHTML );
        this.$el.append(cancelTemplate({
            color: "#ffffff",
            background: "#59c939",
            title: "New Recommendation"
        }));
        
        if (typeof this.prompt != 'undefined') {
            this.recommendation.set("tagstring", this.prompt.get("tagstring"));
        }
        
        // template
        var template = _.template( commentsHTML );
        comments = $(template(this.recommendation.toJSON()));
        this.$el.append(comments);
        
        // Load thing
        comments.find(".thing").solutiondetails(this.recommendation.toJSON());
        
        // tags
        $('#tags').tokenfield({delimiter : ' ', createTokensOnBlur: true});
        
        // Set focus on empty field
        if (this.recommendation.get("tagstring") == "") {
	        $('#tags-tokenfield').focus();
        } else {
	        $('#comments').focus();
        }
        
        that = this;
        
        $('.submit').one("click", function() {

			// Replace the icon with a progress indicator
			$(this).find("i").toggleClass("fa-plus-square fa-square fa-spin");

            // Pull the (new) data
            that.recommendation.set({
                "tags": $("#tags").val().toLowerCase().split(" "),
                "comments": $("#comments").val()
            }); 
            
            // Sync the model
            that.recommendation.save(null, {
                success: function() {
	                
                    // Delete the prompt
                    if (typeof that.prompt != 'undefined') {
						that.prompt.destroy({
							success: function() {
								// Go back in history
								parent.history.go(-1);
								return false;
							}
						});
                    } else {
	                    // Go back in history
						parent.history.go(-1);
						return false;
                    }
                },
                error: function(model, response, options) {
					// What to do here? Bail out, oh well.
					// Go back in history
					parent.history.go(-1);
					return false;
                }
            });
    
    	  });
        
    },
    
    remove: function() {
	    this.$el.html("");
    }

  });

  return view;
  
});
