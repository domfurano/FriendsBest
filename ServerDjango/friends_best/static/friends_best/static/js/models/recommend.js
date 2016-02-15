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
/*
		url: function() {
			return '/fb/api/recommend/'+this.id+'/';
		},
*/
	});
	
	return RecommendModel;
	
});