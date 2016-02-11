define([
  'underscore',
  'backbone',
  'models/query',
], function(_, Backbone, QueryModel){
  
	var QueriesCollection = Backbone.Collection.extend({
		url: '/fb/api/query/',
		model: QueryModel,
		defaults: {
			tags: []
		},
		comparator: function(model) {
    		stamp = (new Date(model.get("timestamp")).getTime()/1000);
            return -stamp; // Note the minus!
		}
	});
	
	return QueriesCollection;
	
});