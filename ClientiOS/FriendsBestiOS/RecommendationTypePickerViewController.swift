//
//  RecommendationTypePicker.swift
//  FriendsBest
//
//  Created by Dominic Furano on 3/3/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit

class RecommendationTypePickerView: UIView {
    override func drawRect(rect: CGRect) {
        let context: CGContext = UIGraphicsGetCurrentContext()!
        CGContextClearRect(context, bounds)
        
        CommonUIElements.drawGradientForContext(
            [
                UIColor.colorFromHex(0xfefefe).CGColor,
                UIColor.colorFromHex(0xc8ced0).CGColor
            ],
            frame: self.frame,
            context: context
        )
    }
}

class RecommendationTypePickerViewController: UIViewController {
    
    var googlePlacesButton: UIButton?
    
    override func loadView() {
        super.loadView()
        self.view = RecommendationTypePickerView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        googlePlacesButton = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        googlePlacesButton!.backgroundColor = UIColor.greenColor()
        googlePlacesButton!.setTitle("Google Places", forState: .Normal)
        googlePlacesButton!.setTitleColor(UIColor.redColor(), forState: .Normal)
        googlePlacesButton!.center = self.view.center
        googlePlacesButton!.translatesAutoresizingMaskIntoConstraints = false
        googlePlacesButton!.addTarget(self, action: "googlePlacesSelected", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(googlePlacesButton!)
    }
    
    func googlePlacesSelected() {
        NSLog("foo")
    }
    
    
}