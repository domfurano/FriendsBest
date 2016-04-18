(function($) {
  
  	var map = false;
  
	function gotDetails(place, status) {
	
		$el = $.fn.placedetails.$el;
		var settings = $.fn.placedetails.settings;
		
		if (status == google.maps.places.PlacesServiceStatus.OK) {
			
			console.log(place);
			console.log($el);
			
			// Build address
			var address = '';
			if (place.address_components) {
				address = [
					(place.address_components[0] && place.address_components[0].short_name || ''),
					(place.address_components[1] && place.address_components[1].short_name || ''),
					(place.address_components[2] && place.address_components[2].short_name || '')
				].join(' ');
			}
			
			// Load details
			details = $("<div class='place'><div class='name'>" + place.name + "</div><div class='address'>" + address + "</div></div>")
			$el.html(details);
			
		} else {
			
			// Might have had plain text...
			// Load details
			details = $("<div class='place'><div class='name'>" + settings.placeid + "</div><div class='address'></div></div>")
			$el.html(details);
			
		}
	}
  
	// Constructor
	$.fn.placedetails = function(options) {
		
		console.log(options);
		
		$.fn.placedetails.$el = this;
		
		// Setup defaults
		$.fn.placedetails.settings = $.extend({}, $.fn.placedetails.defaults, options);
		var settings = $.fn.placedetails.settings;
		
		// Map
		if(!map) {
			map = new google.maps.Map($("<div>"), {});	
		}
		
		
		// Get details
		if(settings.placeid) {
			
			console.log("Going to get details for " + settings.placeid);
			console.log($.fn.placedetails.$el);
			
			var request = {
			  placeId: settings.placeid
			};
			
			service = new google.maps.places.PlacesService(map);
			service.getDetails(request, gotDetails);
		}

	};

	// placedetails defaults
	$.fn.placedetails.defaults = {
		placeid: false
	};
	
})(jQuery);