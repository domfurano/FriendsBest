(function($) {
  
  	var map = false;
  	var service = false;
  
  	function getHostFromURL(href) {
        
        if(href.indexOf("://") == -1) {
            if(href.indexOf("//") > -1) {
                href = "http:" + href;
            } else {
                href = "http://" + href;
            }    
        }
        
        var l = document.createElement("a");
        l.href = href;
        return l;
    };
  
	// Constructor
	$.fn.solutiondetails = function(options) {
		
		// Setup defaults
		var solution = $.extend({}, $.fn.solutiondetails.defaults, options);
		var $el = this;
		
		console.log($el);
		console.log(solution);
		
		// Map for place
		if(!map) {
			map = google.maps.Map;	
		}
		
		if(!service) {
			service = new google.maps.places.PlacesService(document.createElement('div'));
		}
		
		// Get details
		switch(solution.type) {
			case 'place':
				// Load place info
				service.getDetails({placeId: solution.detail}, gotPlace);
				break;
			case 'url':
				// Load url
				url = getHostFromURL(solution.detail)
				details = $("<div class='url'><div class='host'>" + url.hostname + "</div><div class='full'>" + url + "</div></div>")
				$el.html(details);
				break;
			default:
				// Load text
				details = $("<div class='text'><div class='custom'>" + solution.detail + "</div></div>")
				$el.html(details);
		}
		
		function gotPlace(place, status) {
		
			if (status == google.maps.places.PlacesServiceStatus.OK) {
				
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
				details = $("<div class='place'><div class='name'>" + solution.detail + "</div><div class='address'>No specific location</div></div>")
				$el.html(details);
				
			}
		}

	};

	// placedetails defaults
	$.fn.solutiondetails.defaults = {
	};
	
})(jQuery);