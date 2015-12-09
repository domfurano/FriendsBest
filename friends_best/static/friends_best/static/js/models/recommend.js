define([
  'underscore',
  'backbone'
], function(_, Backbone){
  
	var RecommendModel = Backbone.Model.extend({
		urlRoot: '/api/recommend',
		defaults: {
			user: 1,			// Hard coded as 1 for prototype
			description: "",
			tags: "",
			comments: "",
		},
	});
	
	return RecommendModel;
	
});