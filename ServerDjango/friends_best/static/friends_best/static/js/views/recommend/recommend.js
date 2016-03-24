define([
  'jquery',
  'underscore',
  'backbone',
  'models/recommend',
  'text!templates/standard/cancel.html',
  'text!templates/standard/cancelsubmit.html',
  'text!templates/recommend/picker.html',
  'text!templates/recommend/place.html',
  'text!templates/recommend/url.html',
  'text!templates/recommend/text.html',
  'text!templates/recommend/comments.html',
], function($, _, Backbone, RecommendModel, cancelHTML, cancelsubmitHTML, pickerHTML, placeHTML, urlHTML, textHTML, commentsHTML){

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
            title: "Recommendation Type",
        }));
        
        // Type picker
        var pickerTemplate = _.template( pickerHTML );
        this.$el.append(pickerTemplate());
        
        this.pickerButton("PLACE");
        this.pickerButton("URL");
        this.pickerButton("TEXT");
        
        $("#PLACE").hide();
        
    },
    
    pickerButton: function(type) {
        that = this;
        $("#"+type).click(function() {
            that.recommendation.set("type", type);
            that.render();
        });
    },
    
    PLACE: function() {
        // Cancel UI
        var cancelTemplate = _.template( cancelHTML );
        this.$el.append(cancelTemplate({
            color: "#ffffff",
            background: "#59c939",
            title: "Place"
        }));
    },
    
    URL: function() {
        // Cancel UI
        var cancelTemplate = _.template( cancelHTML );
        this.$el.append(cancelTemplate({
            color: "#ffffff",
            background: "#59c939",
            title: "Website"
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
                that.recommendation.set("detail", text);
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
    
    TEXT: function() {
        // Cancel UI
        var cancelTemplate = _.template( cancelHTML );
        this.$el.append(cancelTemplate({
            color: "#ffffff",
            background: "#59c939",
            title: "Custom"
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
            title: "More Details"
        }));
        
        if (typeof this.prompt != 'undefined') {
            this.recommendation.set("tagstring", this.prompt.get("tagstring"));
        }
        
        console.log(this.recommendation.toJSON());
        
        // tag and comment entry
        var template = _.template( commentsHTML );
        this.$el.append(template(this.recommendation.toJSON()));
        
        $('#tags').tokenfield({delimiter : ' ', createTokensOnBlur: true});
        
        that = this;
        
        $('.submit').click(function() {

            // Delete the prompt
            if (typeof that.prompt != 'undefined') {
              that.prompt.destroy();
            }
            
            // Pull the (new) data
            that.recommendation.set({
                "tags": $("#tags").val().toLowerCase().split(" "),
                "comments": $("#comments").val()
            });
            
            // Sync the model
            that.recommendation.save();
            
            // Go back in history
            parent.history.go(-1);
            return false;
    
    	  });
        
    },
    
    remove: function() {
	    this.$el.html("");
    }

  });

  return view;
  
});