define([
  'underscore',
  'backbone'
], function(_, Backbone){
  
	var RecommendModel = Backbone.Model.extend({
		urlRoot: '/fb/api/recommend/',
		defaults: {
			description: "",
			tags: [],
			comments: "",
		},
	});
	
	return RecommendModel;
	
});