//
//  SolutionDetailTableViewCell.swift
//  FriendsBest
//
//  Created by Dominic Furano on 4/4/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit

class SolutionDetailTableViewCell: UITableViewCell {
    
    
    var didUpdateConstraints: Bool = false
    override func updateConstraints() {
        if !didUpdateConstraints {
            
            didUpdateConstraints = true
        }

    }
    
}
