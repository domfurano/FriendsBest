define([
  'underscore',
  'backbone',
  'models/prompt',
], function(_, Backbone, PromptModel){
  
	var Collection = Backbone.Collection.extend({
		url: '/fb/api/prompt/',
		model: PromptModel,
	});
	
	return Collection;
	
});