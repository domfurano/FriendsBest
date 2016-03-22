define([
  'underscore',
  'backbone'
], function(_, Backbone){
  
	var RecommendModel = Backbone.Model.extend({
		urlRoot: '/fb/api/recommend/',
		defaults: {
    		type: null,
            detail: null,
			tags: [],
			comments: ""
		},
	});
	
	return RecommendModel;
	
});
