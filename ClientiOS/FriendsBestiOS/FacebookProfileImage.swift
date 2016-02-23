//
//  FacebookProfilePictureGetter.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 2/23/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import QuartzCore
import UIKit
import FBSDKCoreKit

class FacebookProfileImage {
    
    private let profilePictureView: FBSDKProfilePictureView
    private var _image: UIImage?
    private var _imageView: UIImageView?
    
    var image: UIImage {
        get {
            if self._image == nil {
                self.viewToImage()
            }
            return self._image!
        }
    }
    
    var imageView: UIImageView {
        get {
            if self._image == nil {
                self.viewToImage()
            }
            
            if self._imageView == nil {
                self.imageToView()
            }

            assert(self._image != nil)
            assert(self._imageView != nil)

            return self._imageView!
        }
    }
    
    
    init(profileID: String? = nil) {
        self.profilePictureView = FBSDKProfilePictureView(frame: CGRectMake(0,0,100,100))
        if profileID != nil {
            // The default ID is the user who is logged in using this app
            self.profilePictureView.profileID = profileID
        }
        self.profilePictureView.pictureMode = FBSDKProfilePictureMode.Square
    }
    
    private func viewToImage() {
        UIGraphicsBeginImageContextWithOptions(
            self.profilePictureView.frame.size,
            self.profilePictureView.opaque,
            0.0
        )

        self.profilePictureView.drawViewHierarchyInRect(
            self.profilePictureView.bounds,
            afterScreenUpdates: true
        )
        
        self._image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
    }
    
    private func imageToView() {
        self._imageView = UIImageView(image: self._image!)
    }
}













