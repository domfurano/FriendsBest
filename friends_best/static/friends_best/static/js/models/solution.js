define([
  'underscore',
  'backbone',
  'collections/solutions',
], function(_, Backbone){
  
	var SolutionModel = Backbone.Model.extend({
		initialize: function(options) {
		    this.id = options.id;
		    this.set('solutions', new SolutionsCollection());
		},
		defaults: {
			
		},
	});
	
	return QueryModel;
	
});