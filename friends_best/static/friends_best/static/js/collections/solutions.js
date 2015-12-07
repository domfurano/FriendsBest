define([
  'underscore',
  'backbone'
], function(_, Backbone){
  
	var SolutionsCollection = Backbone.Collection.extend({
		url: function() {
			return '/api/query/'+this.id
		},
		defaults: {
			emptyField: "empty",
		},
		parse: function(response, options){
/*
			data = [];
			_.each(response, function(value, key, list) {
				data.push({id: key, tags: value});
			});
			return data;
*/
		}
	});
	
	return SolutionsCollection;
	
});