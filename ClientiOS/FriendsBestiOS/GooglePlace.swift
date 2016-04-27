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
    //"AIzaSyAhLJ06sDGt8x9mPFETmuwTXSG4Sx1E-p8"
//    static let APIKey: String = "AIzaSyAhLJ06sDGt8x9mPFETmuwTXSG4Sx1E-p8"//"AIzaSyAYaNO8DDk-1s_IFnQgBA3QGqce21JwIZg"
    
    
    static let GOOGLE_API_KEY: String = "AIzaSyCiW8jCl6JfJd5kx7js7cb-e32GTXNopyE"// FB:"AIzaSyC7VG-bEW5bKaNA6DjEK58NH3YpzNE9gEI"
    
    // MARK: Properties
    var placeID: String
    var name: String
    var latitude: Double
    var longitude: Double
    var formattedAddress: String?
    var addressComponents: [String: String]?
    var picture: UIImageView?
    var cid: String?
    
    // MARK: Types
    struct PropertyKey {
        static let placeIDKey = "ID"
        static let nameKey = "name"
        static let formattedAddressKey = "photo"
        static let latitudeKey = "latitude"
        static let longitudeKey = "longitude"
        static let cidKey = "cid"
    }
    
    
    init(placeID: String, name: String, formattedAddress: String?, latitude: Double, longitude: Double, cid: String?) {
        self.placeID = placeID
        self.name = name
        self.formattedAddress = formattedAddress
        self.latitude = latitude
        self.longitude = longitude
        self.cid = cid
        super.init()
    }
    
    // MARK: Static methods
    
    static func loadPlace(placeID: String, callback: ((successful: Bool, place: GooglePlace?) -> Void)?) {
        PINCache.sharedCache().objectForKey(placeID) { (cache: PINCache, key: String, object: AnyObject?) in
            if let place: GooglePlace = object as? GooglePlace {
                dispatch_async(dispatch_get_main_queue(), {
                    callback?(successful: true, place: place)
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    GMSPlacesClient.sharedClient().lookUpPlaceID(placeID, callback: { (gmsPlace: GMSPlace?, error: NSError?) in
                        if error != nil {
//                            NSLog("\(error!.description)")
//                            NSLog("\(error!.debugDescription)")
                            callback?(successful: false, place: nil)
                        } else {
                            if let gmsPlace = gmsPlace {
                                let place: GooglePlace = GooglePlace(
                                    placeID: placeID,
                                    name: gmsPlace.name,
                                    formattedAddress: gmsPlace.formattedAddress,
                                    latitude: gmsPlace.coordinate.latitude,
                                    longitude: gmsPlace.coordinate.longitude,
                                    cid: nil
                                )
                                loadCid(placeID)
                                PINCache.sharedCache().setObject(place, forKey: placeID)
                                dispatch_async(dispatch_get_main_queue(), {
                                    callback?(successful: true, place: place)
                                })
                            }
                        }
                    })
                })
            }
        }
    }
    
    static func loadCid(placeID: String) {
        let URLString: String = "https://maps.googleapis.com/maps/api/place/details/json?key=\(GOOGLE_API_KEY)&placeid=\(placeID)"
        
        let configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        //        configuration.HTTPAdditionalHeaders = ["Authorization": token]
        let session: NSURLSession = NSURLSession(configuration: configuration)
        
        //        let queryString: String = "query/"
        guard let queryURL: NSURL = NSURL(string: URLString) else {
            return
        }
        
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: queryURL)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("hovercraft.FriendsBestiOS", forHTTPHeaderField: "referer")
        
        session.dataTaskWithRequest(request, completionHandler: {
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            if let error = error {
                NSLog("Error - Google API - loadCid() - \(error.localizedDescription)")
                NetworkQueue.instance.tryAgain()
                return
            }
            
            guard let data = data else {
                NSLog("Error - Google API - loadCid() - no data")
                NetworkQueue.instance.tryAgain()
                return
            }
            
            let resultDict: NSDictionary?
            do {
                resultDict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? NSDictionary
            } catch {
                NSLog("Error - Google API - loadCid() - Unable to parse JSON")
            }
            
            //            if !self.responseHasExpectedStatusCodes(response, expectedStatusCodes: [201], funcName: "postNewQuery") {
            //                NetworkQueue.instance.tryAgain()
            //                return
            //            }
            
            //            guard let queryDict: NSDictionary = self.getNSDictionaryFromJSONdata(data, funcName: "postNewQuery") else {
            //                NetworkQueue.instance.tryAgain()
            //                return
            //            }
            //
            //            let query: Query = self.getQuery(queryDict)
            
            //            dispatch_async(dispatch_get_main_queue(), {
            //                self.networkDAODelegate?.queryFetched(query)
            //                callback?()
            //            })
            //            NetworkQueue.instance.dequeue()
        }).resume()
    }
    
    // MARK: NSCoding
    
    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(placeID, forKey: PropertyKey.placeIDKey)
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(formattedAddress, forKey: PropertyKey.formattedAddressKey)
        aCoder.encodeDouble(latitude, forKey: PropertyKey.latitudeKey)
        aCoder.encodeDouble(longitude, forKey: PropertyKey.longitudeKey)
        aCoder.encodeObject(cid, forKey: PropertyKey.cidKey)
    }
    
    @objc required convenience init?(coder aDecoder: NSCoder) {
        let placeID: String = aDecoder.decodeObjectForKey(PropertyKey.placeIDKey) as! String
        let name: String = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        let formattedAddress: String? = aDecoder.decodeObjectForKey(PropertyKey.formattedAddressKey) as? String
        let cid: String? = aDecoder.decodeObjectForKey(PropertyKey.cidKey) as? String
        let latitude: Double = aDecoder.decodeDoubleForKey(PropertyKey.latitudeKey)
        let longitude: Double = aDecoder.decodeDoubleForKey(PropertyKey.longitudeKey)
        self.init(placeID: placeID, name: name, formattedAddress: formattedAddress, latitude: latitude, longitude: longitude, cid: cid)
    }
    
}
