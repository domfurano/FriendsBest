define([
  'underscore',
  'backbone'
], function(_, Backbone){
  
	var model = Backbone.Model.extend({
		urlRoot: '/fb/api/friend/',
		defaults: {
		},
	});
	
	return model;
	
});
