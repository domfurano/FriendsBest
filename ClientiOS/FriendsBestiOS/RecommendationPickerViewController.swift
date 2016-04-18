//
//  RecommendationPickerViewController.swift
//  FriendsBest
//
//  Created by Dominic Furano on 4/10/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import UIKit

class RecommendationPickerViewController: UIViewController {
    
    enum PickerButtonType {
        case custom, link, place
    }
    
    var buttonPushedDelegate: (buttonType: PickerButtonType) -> Void = { _ in }
    var pickerHiddenDelegate: () -> Void = { }
    
    var pickerView: RecommendationTypePickerView {
        get {
            return view as! RecommendationTypePickerView
        }
    }
    
    override func loadView() {
        view = RecommendationTypePickerView()
    }
    
    override func viewDidLoad() {
        pickerView.customButtonDelegate = {
            self.dismissViewControllerAnimated(false, completion: {
                self.buttonPushedDelegate(buttonType: PickerButtonType.custom)
                self.pickerHiddenDelegate()
            })
        }
        
        pickerView.linkButtonDelegate = {
            self.dismissViewControllerAnimated(false, completion: {
                self.buttonPushedDelegate(buttonType: PickerButtonType.link)
                self.pickerHiddenDelegate()
            })
        }
        
        pickerView.placeButtonDelegate = {
            self.dismissViewControllerAnimated(false, completion: {
                self.buttonPushedDelegate(buttonType: PickerButtonType.place)
                self.pickerHiddenDelegate()
            })
        }
        
        pickerView.pickerHidden = {
            self.dismissViewControllerAnimated(false, completion: {
                self.pickerHiddenDelegate()
            })
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        pickerView.show()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        pickerView.hide(true)
    }
    
}