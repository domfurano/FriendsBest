define([
  'jquery',
  'underscore',
  'backbone',
  'text!templates/home/menu.html',
], function($, _, Backbone, menuHTML){

  var view = Backbone.View.extend({
    el: $("footer"),

    render: function(){
		var menuTemplate = _.template( menuHTML, {} );
		this.$el.html(menuTemplate({id: FB.getAuthResponse().userID}));
		this.show();
    },
    show: function() {
		this.$el.show();
    },
    hide: function() {
		this.$el.hide();
    },
    remove: function() {
	    this.$el.html("");
    }
  });

  return view;
  
});
