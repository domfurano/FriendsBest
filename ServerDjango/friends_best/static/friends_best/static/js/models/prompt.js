define([
  'underscore',
  'backbone',
], function(_, Backbone){
  
	var Model = Backbone.Model.extend({
		urlRoot: '/fb/api/prompt/',
	});
	
	return Model;
	
});