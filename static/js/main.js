require.config({
  paths: {
    jquery: 'vendor/jquery.min',
    'jquery.ui': 'vendor/jquery-ui.min',
    'jquery.ui.tp': 'vendor/jquery.ui.touch-punch.min',
    bootstrap: 'vendor/bootstrap',
    tokenfield: 'vendor/bootstrap-tokenfield',
    underscore: 'vendor/underscore',
    backbone: 'vendor/backbone',
    templates: '../templates'
  },
  shim: {
	  'jquery.ui.tp': {
		  deps: ['jquery.ui'],
	  },
	  tokenfield: {
		  deps: ['jquery', 'bootstrap'],
	  }
  }
});

require(['app'],function(App){
	console.log("main.js")
	App.initialize();
});