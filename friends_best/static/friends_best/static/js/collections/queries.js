define([
  'underscore',
  'backbone',
  'models/query',
], function(_, Backbone, QueryModel){
  
	var QueriesCollection = Backbone.Collection.extend({
		url: '/api/query',
		model: QueryModel,
		defaults: {
			tags: [],
		},
		parse: function(response, options){
			data = [];
			_.each(response, function(value, key, list) {
				data.push({id: key, tags: value});
			});
			return data;
		}
	});
	
	return QueriesCollection;
	
});