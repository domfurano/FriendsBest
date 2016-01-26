define([
  'underscore',
  'backbone',
  'collections/solutions',
], function(_, Backbone, SolutionsCollection){
  
	var QueryModel = Backbone.Model.extend({
		urlRoot: '/fb/api/query/',
/*
		url: function() {
			return '/fb/api/query/'+this.id;
		},
*/
		initialize: function(options) {
		    //this.id = options.id;
		    //this.set('solutions', new SolutionsCollection());
		},
		defaults: {
			
		},
	});
	
	return QueryModel;
	
});