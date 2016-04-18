(function($) {
  
  function makeAutocomplete() {
    
    var map = $.fn.placefinder.map;
    var settings = $.fn.placefinder.settings;
    
    // Create autocomplete
    var autocomplete = new google.maps.places.Autocomplete(settings.input.get(0));
    settings.input.submit(function() {
      return false;
    })
    $.fn.placefinder.autocomplete = autocomplete;
    
    // Create Marker
    var marker = new google.maps.Marker({
      map: map,
      anchorPoint: new google.maps.Point(0, 0)
    });
    
    // Create InfoWindow
    var infowindow = new google.maps.InfoWindow({
        pixelOffset: new google.maps.Size(0, 30)
    });
    
    // Create InfoBubble
    var infoBubble = new InfoBubble({
        maxWidth: 320,
        hideCloseButton: true,
        borderWidth: 1,
        shadowStyle: 0,
        borderRadius: 4,
        pixelOffset: new google.maps.Size(0, 30),
        padding: 10,
        backgroundColor: '#fff',
        backgroundClassName: 'map-location'
    });
    
    autocomplete.addListener('place_changed', function() {
    
      // Clear search field
      settings.input.val("");
    
      marker.setVisible(false);
      
      var place = autocomplete.getPlace();
      
      console.log(place);
      
      if (!place.geometry) {
        window.alert("Autocomplete's returned place contains no geometry");
        return;
      }

      // If the place has a geometry, then present it on a map.
      if (place.geometry.viewport) {
        map.fitBounds(place.geometry.viewport);
      } else {
        map.setCenter(place.geometry.location);
        map.setZoom(15);
      }
      marker.setPosition(place.geometry.location);
      //marker.setVisible(true);

      var address = '';
      if (place.address_components) {
        address = [
          (place.address_components[0] && place.address_components[0].short_name || ''),
          (place.address_components[1] && place.address_components[1].short_name || ''),
          (place.address_components[2] && place.address_components[2].short_name || '')
        ].join(' ');
      }
      
      //infowindow.setContent('<div class="map-location"><strong>' + place.name + '</strong><br>' + address + '</div><div class="create"><i class="fa fa-chevron-right fa-2x" style="color:#59c939"></i></div>');
      infoBubble.setContent('<strong>' + place.name + '</strong><br>' + address);
      infoBubble.open(map, marker);
      //infowindow.open(map, marker);
      
    });
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
  
  $.fn.placefinder = function(options) {
    
    // Setup defaults
    $.fn.placefinder.settings = $.extend({}, $.fn.placefinder.defaults, options);
    var settings = $.fn.placefinder.settings;
    
    // Create map
    if(settings.location.latitude == 0) {
      navigator.geolocation.getCurrentPosition(
        function(position) {
          $.fn.placefinder.settings.location = position.coords;
          makeMap();
        }, makeMap
      );
    } else {
      makeMap();
    }
  };
  $.fn.placefinder.defaults = {
    location: {
      latitude: 0,
      longitude: 10,
    }
  };
})(jQuery);