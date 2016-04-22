//
//  GooglePlace.swift
//  FriendsBest
//
//  Created by Dominic Furano on 4/20/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import Foundation
import PINCache
import GoogleMaps

class GooglePlace: NSObject, NSCoding {
    
    // MARK: Properties
    var placeID: String
    var name: String
    var formattedAddress: String?
    var addressComponents: [String: String]?
    var picture: UIImageView?
    
    // MARK: Types
    struct PropertyKey {
        static let placeIDKey = "ID"
        static let nameKey = "name"
        static let formattedAddressKey = "photo"
    }
    
    
    init(placeID: String, name: String, formattedAddress: String?) {
        self.placeID = placeID
        self.name = name
        self.formattedAddress = formattedAddress
        super.init()
    }
    
    // MARK: Static methods
    
    static func loadPlace(placeID: String, callback: (place: GooglePlace) -> Void) {
        PINCache.sharedCache().objectForKey(placeID) { (cache: PINCache, key: String, object: AnyObject?) in
            if let place: GooglePlace = object as? GooglePlace {
                dispatch_async(dispatch_get_main_queue(), {
                    callback(place: place)
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    GMSPlacesClient.sharedClient().lookUpPlaceID(placeID, callback: { (gmsPlace: GMSPlace?, error: NSError?) in
                        if error != nil {
                            NSLog("\(error!.description)")
                            NSLog("\(error!.debugDescription)")
                        } else {
                            if let gmsPlace = gmsPlace {
                                let place: GooglePlace = GooglePlace(placeID: placeID, name: gmsPlace.name, formattedAddress: gmsPlace.formattedAddress)
                                PINCache.sharedCache().setObject(place, forKey: placeID)
                                dispatch_async(dispatch_get_main_queue(), {
                                    callback(place: place)
                                })
                            }
                        }
                    })
                })
            }
        }
    }

    // MARK: NSCoding

    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(placeID, forKey: PropertyKey.placeIDKey)
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(formattedAddress, forKey: PropertyKey.formattedAddressKey)
    }

    @objc required convenience init?(coder aDecoder: NSCoder) {
        let placeID: String = aDecoder.decodeObjectForKey(PropertyKey.placeIDKey) as! String
        let name: String = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        let formattedAddress: String = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        self.init(placeID: placeID, name: name, formattedAddress: formattedAddress)
    }
    
}
