require.config({
  paths: {
	async: 'vendor/async',
    jquery: 'vendor/jquery.min',
    'jquery.ui': 'vendor/jquery-ui.min',
    'jquery.mobile': 'vendor/jquery.mobile.min',
    'jquery.ui.tp': 'vendor/jquery.ui.touch-punch.min',
    bootstrap: 'vendor/bootstrap',
    tokenfield: 'vendor/bootstrap-tokenfield',
    placefinder: 'placefinder',
    underscore: 'vendor/underscore',
    backbone: 'vendor/backbone',
    templates: '../templates',
    'facebook': '//connect.facebook.net/en_US/sdk'
  },
  shim: {
	  'jquery.ui.tp': {
		  deps: ['jquery.ui'],
	  },
	  tokenfield: {
		  deps: ['jquery', 'bootstrap'],
	  },
	  placefinder: {
		  deps: ['jquery', 'bootstrap'],
	  },
	  'facebook' : {
	      exports: 'FB'
	  },
	  'app' : {
		  exports: 'APP'
	  }
  }
});

require(['app'],function(App){
	console.log("main.js")
	App.initialize();
});