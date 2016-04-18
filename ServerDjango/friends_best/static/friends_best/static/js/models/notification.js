define([
  'underscore',
  'backbone',
], function(_, Backbone){
  
	var Model = Backbone.Model.extend({
		urlRoot: '/fb/api/notification/',
	});
	
	return Model;
	
});
