define([
  'underscore',
  'backbone',
  'models/friend',
], function(_, Backbone, FriendModel){
  
	var collection = Backbone.Collection.extend({
		url: '/fb/api/friend/',
		model: FriendModel,
		defaults: {
		},
	});
	
	return collection;
	
});