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
    solutiondetails: 'solutiondetails',
    underscore: 'vendor/underscore',
    backbone: 'vendor/backbone',
    templates: '../templates',
    'facebook': '//connect.facebook.net/en_US/sdk',
    'maps': 'async!//maps.google.com/maps/api/js?libraries=places&key=AIzaSyA1zoAVAJvKmZGwCFmdwXP3Gi73Ck-kn0k',
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
	  placedetails: {
		  deps: ['jquery', 'maps'],
	  },
	  'facebook' : {
	      exports: 'FB'
	  },
	  'app' : {
		  exports: 'APP'
	  },
	  'bootstrap' : {
    	  deps: ['jquery'],
	  }
  }
});

require(['app'],function(App){
	console.log("main.js")
	App.initialize();
});