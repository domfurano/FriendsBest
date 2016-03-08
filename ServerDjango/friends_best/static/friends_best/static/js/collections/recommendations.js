define([
  'underscore',
  'backbone',
  'models/recommend',
], function(_, Backbone, RecommendModel){
  
	var collection = Backbone.Collection.extend({
		url: '/fb/api/recommend/',
		model: RecommendModel,
		defaults: {
		},
	});
	
	return collection;
	
});