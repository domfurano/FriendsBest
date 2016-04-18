(function($) {
  
	function makeAutocomplete() {	
		var map = $.fn.placefinder.map;
		var settings = $.fn.placefinder.settings;
		
		// Hide box
		settings.result.hide();
		
		// Create autocomplete
		$.fn.placefinder.autocomplete = new google.maps.places.Autocomplete(settings.input.get(0));
		settings.input.submit(function() {
		  return false;
		});
		
		// Create Marker
		$.fn.placefinder.marker = new google.maps.Marker({
		  map: map,
		  anchorPoint: new google.maps.Point(0, 0)
		});
		
		$.fn.placefinder.autocomplete.addListener('place_changed', placeChanged);
	}
  
	function placeChanged() {
		
		var settings = $.fn.placefinder.settings;
		var map = $.fn.placefinder.map;
		var marker = $.fn.placefinder.marker;
		var autocomplete = $.fn.placefinder.autocomplete;
		
		// Update marker
		marker.setVisible(false);
		var place = autocomplete.getPlace();
		if (!place.geometry) {
			window.alert("Something went wrong.");
			return;
		}
		if (place.geometry.viewport) {
			map.fitBounds(place.geometry.viewport);
		} else {
			map.setCenter(place.geometry.location);
			map.setZoom(15);
		}
		marker.setPosition(place.geometry.location);
		marker.setVisible(true);
		
		showResult(place);
	}
	
	function showResult(place) {
		
		var settings = $.fn.placefinder.settings;
		
		// Build address
		var address = '';
		if (place.address_components) {
			address = [
				(place.address_components[0] && place.address_components[0].short_name || ''),
				(place.address_components[1] && place.address_components[1].short_name || ''),
				(place.address_components[2] && place.address_components[2].short_name || '')
			].join(' ');
		}
		
		// Clear and hide search field
		settings.input.hide();
		settings.input.val("");
		
		// Show result
		var result = settings.result;
		result.find(".name").html(place.name);
		result.find(".address").html(address);
		result.find(".cancel").off().one("click", cancelResult);
		result.find(".next").off().one("click", function() {
			console.log(place);
			settings.pick(place.name, address, place.place_id)
		});
		result.show();
	}
	
	function cancelResult() {
		
		var settings = $.fn.placefinder.settings;
		var marker = $.fn.placefinder.marker;
		var autocomplete = $.fn.placefinder.autocomplete;
		var result = settings.result;
		
		// Hide result
		result.hide();
		
		// Hide marker
		marker.setVisible(false);
		
		// Show search again
		settings.input.show();
	}
  
	function makeMap() {
		var settings = $.fn.placefinder.settings;
		
		// Create map
		$.fn.placefinder.map = new google.maps.Map(settings.map.get(0), {
			center: {lat: settings.location.latitude, lng: settings.location.longitude},
			zoom: 11,
			streetViewControl: false,
			mapTypeId: google.maps.MapTypeId.ROADMAP,
			mapTypeControl: false,
			draggable: true
		});
		
		// Create search autocomplete
		makeAutocomplete();
	}
  
	// Constructor
	$.fn.placefinder = function(options) {
			
		// Setup defaults
		$.fn.placefinder.settings = $.extend({}, $.fn.placefinder.defaults, options);
		var settings = $.fn.placefinder.settings;
		
		// Create map
		if(settings.location.latitude == 0) {
			// Ask browser for current location
			navigator.geolocation.getCurrentPosition(
				function(position) {
					$.fn.placefinder.settings.location = position.coords;
					makeMap();
				}, makeMap);
		} else {
			// Go to location passed as option to contructor
			makeMap();
		}
	};

	// Placefinder defaults
	$.fn.placefinder.defaults = {
		location: {
			latitude: 0,
			longitude: 10,
		},
		pick: function(name, address, placeid) {
		}
	};
	
})(jQuery);