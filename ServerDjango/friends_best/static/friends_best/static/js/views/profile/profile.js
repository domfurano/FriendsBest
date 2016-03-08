 define([
  'jquery',
  'underscore',
  'backbone',
  'text!templates/home/menu.html',
  'text!templates/profile/menu.html',
  'models/me',
], function($, _, Backbone, menuHTML, profileMenuHTML, meModel){

  var view = Backbone.View.extend({
    el: $(".view"),
    visible: true,

	initialize: function() {
		this.visible = true;
		this.model = new meModel();
		this.model.on("change", this.menu, this);
		this.model.fetch();
	},
    
    menu: function() {
	    
	    if(this.visible) {
		    var profileMenuTemplate = _.template( profileMenuHTML );
		    this.$el.append(profileMenuTemplate(this.model.toJSON()));
		    image = FB.image.clone().width(150).height(150).addClass("img-circle");
			this.$el.find(".photo").append(image);
		}
		
    },
    
    remove: function() {
	    this.$el.html("");
	    this.visible = false;
    }

  });

  return view;
  
});
