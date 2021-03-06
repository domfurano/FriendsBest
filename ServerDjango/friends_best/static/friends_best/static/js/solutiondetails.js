require(['jquery', 'waypoint'],
function($) {
  
  	var service = false;
  
  	function getHostFromURL(href) {
        href = href.toString();
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
	$.fn.solutiondetails = function(solution, options) {
		
		// Setup defaults
		var settings = $.extend({}, $.fn.solutiondetails.defaults, options);
		var $el = this;
		
		// Place service
		if(!service) {
			service = new google.maps.places.PlacesService(document.createElement('div'));
		}
				
		// Only load place if this is visible...
		var loaded = false;
		$el.waypoint({
			handler: getDetails,
			context: settings.context,
			offset: '120%'
		});
		
		function getDetails() {
			
			if(loaded) return;
						
			switch(solution.type) {
				case 'place':
					// Load place info
					service.getDetails({placeId: solution.detail}, gotPlace);
					break;
				case 'url':
					// Load url
					url = getHostFromURL(solution.detail)
					details = $("<div class='url' data-url='" + url.href + "'><div class='host'>" + url.hostname + "</div><div class='full'>" + url.href + "</div></div>")
					$el.html(details);
					loaded = true;
					break;
				default:
					// Load text
					details = $("<div class='text'><div class='custom'>" + solution.detail + "</div></div>")
					$el.html(details);
					loaded = true;
			}
		}
		
		function gotPlace(place, status) {
				
			if (status == google.maps.places.PlacesServiceStatus.OK) {
				
				loaded = true;
				
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
				details = $("<div class='place' data-url='" + place.url + "'><div class='name'>" + place.name + "</div><div class='address'>" + address + "</div></div>")
				$el.html(details);
				
			} else if(status == google.maps.places.PlacesServiceStatus.OVER_QUERY_LIMIT) {
				// Try again
				setTimeout(getDetails,1000);
			} else {
				
				loaded = true;
				
				// Might have had plain text...
				// Load details
				details = $("<div class='place'><div class='name'>" + solution.detail + "</div><div class='address'>No specific location</div></div>")
				$el.html(details);
				
			}
		}

	};

	// placedetails defaults
	$.fn.solutiondetails.defaults = {
		context: window
	};
	
});