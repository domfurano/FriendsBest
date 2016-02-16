define([
  'underscore',
  'backbone',
  'collections/solutions',
], function(_, Backbone, SolutionsCollection){
  
	var QueryModel = Backbone.Model.extend({
		urlRoot: '/fb/api/query/',
	});
	
	return QueryModel;
	
});
