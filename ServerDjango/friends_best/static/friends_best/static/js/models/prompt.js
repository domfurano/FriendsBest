define([
  'underscore',
  'backbone',
], function(_, Backbone){
  
	var Model = Backbone.Model.extend({
		urlRoot: '/fb/api/prompt/',
		url: function() {
			return '/fb/api/prompt/'+this.id+'/';
		},
	});
	
	return Model;
	
});