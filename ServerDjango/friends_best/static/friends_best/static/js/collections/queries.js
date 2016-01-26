define([
  'underscore',
  'backbone',
  'models/query',
], function(_, Backbone, QueryModel){
  
	var QueriesCollection = Backbone.Collection.extend({
		url: '/fb/api/query',
		model: QueryModel,
		defaults: {
			tags: []
		},
		comparator: function(model) {
		  return -model.get("id"); // Note the minus!
		}
	});
	
	return QueriesCollection;
	
});