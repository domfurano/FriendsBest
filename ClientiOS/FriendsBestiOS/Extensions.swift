//
//  ExtraStuff.swift
//  FriendsBestiOS
//
//  Created by Dominic Furano on 1/27/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import Foundation

extension UIColor {
    static func colorFromHex(hex: Int) -> UIColor {
        return UIColor(red: ( (CGFloat)( (hex & 0xFF0000) >> 16) ) / 255.0,
            green: ( (CGFloat)( (hex & 0x00FF00) >>  8) ) / 255.0,
            blue: ( (CGFloat)( (hex & 0x0000FF) >>  0) ) / 255.0,
            alpha: 1.0)
    }
}
