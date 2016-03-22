define([
  'jquery',
  'underscore',
  'backbone',
  'models/recommend',
  'text!templates/standard/cancel.html',
  'text!templates/recommend/picker.html',
  'text!templates/recommend/place.html',
  'text!templates/recommend/url.html',
  'text!templates/recommend/text.html',
  'text!templates/recommend/comments.html',
], function($, _, Backbone, RecommendModel, cancelHTML, pickerHTML, placeHTML, urlHTML, textHTML, commentsHTML){

  var view = Backbone.View.extend({
    el: $(".view"),
    
    initialize: function() {
        // Create a recommendation model
        this.recommendation = new RecommendModel();
    },
    
    render: function(){

        this.$el.empty();
        
        // Load correct view based on model
        if(!this.recommendation.has("type")) {
            this.picker();
        } else if(!this.recommendation.has("detail")) {
            (this[this.recommendation.get("type")])();
        } else {
            this.comments();
        }
 
    },
    
    picker: function() {
        
        // Cancel UI
        var cancelTemplate = _.template( cancelHTML );
        this.$el.append(cancelTemplate({
            color: "#ffffff",
            background: "#59c939",
            title: "Recommendation Type"
        }));
        
        // Type picker
        var pickerTemplate = _.template( pickerHTML );
        this.$el.append(pickerTemplate());
        
        this.pickerButton("PLACE");
        this.pickerButton("URL");
        this.pickerButton("TEXT");
        
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
            title: "URL"
        }));
    },
    
    TEXT: function() {
        // Cancel UI
        var cancelTemplate = _.template( cancelHTML );
        this.$el.append(cancelTemplate({
            color: "#ffffff",
            background: "#59c939",
            title: "Custom Text"
        }));
    },
    
    comments: function() {
        // If prompt was specified, show tags
        //if (typeof this.prompt != 'undefined') {
        //    tags = this.prompt.get("tagstring");
        //}
        
        // Cancel UI
        var cancelTemplate = _.template( cancelHTML );
        this.$el.append(cancelTemplate({
            color: "#ffffff",
            background: "#59c939",
            title: "Comments"
        }));
        
        // click or submit
    },
    
    remove: function() {
	    this.$el.html("");
    }

  });

  return view;
  
});
