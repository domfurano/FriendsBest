define([
  'underscore',
  'backbone'
], function(_, Backbone){
  
	var RecommendModel = Backbone.Model.extend({
		urlRoot: '/fb/api/recommend/',
		defaults: {
			detail: "",
			tags: [],
			comments: "",
			type: "TEXT"
		},
	});
	
	return RecommendModel;
	
});
