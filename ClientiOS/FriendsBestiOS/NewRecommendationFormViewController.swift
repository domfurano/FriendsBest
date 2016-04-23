//
//  NewRecommendationFormViewController.swift
//  FriendsBest
//
//  Created by Dominic Furano on 4/5/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import Eureka
import GoogleMaps

enum RecommendationFormType {
    case NEW, EDIT
}

class NewRecommendationFormViewController: FormViewController {
    var newRecommendation: NewRecommendation!
    var type: RecommendationFormType!
    
    var lastString: String? = nil
    
    convenience init(newRecommendation: NewRecommendation, type: RecommendationFormType) {
        self.init()
        self.newRecommendation = newRecommendation
        self.type = type
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftBBitem: UIBarButtonItem = UIBarButtonItem(
            image: CommonUI.nbTimes,
            style: .Plain,
            target: self,
            action: #selector(NewRecommendationFormViewController.dismiss)
        )
        leftBBitem.tintColor = UIColor.whiteColor()
        self.navigationItem.leftBarButtonItem = leftBBitem
        
        let rightBB: UIBarButtonItem = UIBarButtonItem(
            image: CommonUI.fa_plus_square_image,
            style: .Plain,
            target: self,
            action: #selector(NewRecommendationFormViewController.createNewRecommendationButtonPressed)
        )
        rightBB.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem = rightBB
        
        form = Section("Recommendation")
            <<< TextRow() {
                $0.tag = "detail"
                switch self.newRecommendation.type! {
                case .text:
                    $0.value = self.newRecommendation.detail!
                    $0.disabled = false
                case .url:
                    $0.value = self.newRecommendation.detail!
                    $0.disabled = false
                    break
                case .place:
                    $0.value = self.newRecommendation.placeName
                    $0.disabled = true
                    break
                }
                }.cellSetup({ (cell, row) in
                    cell.textField.autocorrectionType = .No
                    cell.textField.autocapitalizationType = .None
                })
            +++ Section("Keywords")
            <<< TextRow() {
                $0.tag = "keywords"
                    $0.value = self.newRecommendation.tagString
                }.cellUpdate({ (cell, row) in
                    cell.textField.autocapitalizationType = .None
                }).onChange({ (row: TextRow) in
                })
            +++ Section("Comments")
            <<< TextAreaRow() {
                $0.tag = "comments"
                if self.newRecommendation.comments != nil {
                    $0.value = self.newRecommendation.comments
                }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBarHidden = false
        navigationController?.navigationBar.barTintColor = CommonUI.fbGreen
        navigationController?.toolbarHidden = true
        title = "New Recommendation"
    }
    
    func dismiss() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func createNewRecommendationButtonPressed() {
        let values: [String: Any?] = form.values(includeHidden: false)
        
        if values["detail"] == nil || values["detail"]! == nil || (values["detail"]!! as! String).isEmpty ||
            values["keywords"] == nil || values["keywords"]! == nil || (values["keywords"]!! as! String).isEmpty {
            return
        }
        
        if newRecommendation.type! == .text {
            newRecommendation.detail = (values["detail"]!! as! String)
        }
        newRecommendation.tags = (values["keywords"]!! as! String).componentsSeparatedByString(" ")
        newRecommendation.comments = values["comments"] == nil ? "" : (values["comments"]!! as! String)
        
        if self.type == .NEW {
            FBNetworkDAO.instance.postNewRecommendtaion(newRecommendation, callback: nil)
        } else {
            FBNetworkDAO.instance.putRecommendation(newRecommendation, callback: nil)
        }
        
        for vc in (navigationController?.viewControllers)! {
            if vc.isKindOfClass(MainScreenViewController) {
                navigationController?.popToViewController(vc, animated: true)
                break
            }
        }
    }
}

final class PlaceImageRow: Row<Bool, PlaceImageCell>, RowType {
    required init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
    }
}

class PlaceImageCell : Cell<Bool>, CellType {
    
    var placeImage: UIImageView {
        get {
            return _placeImage
        }
        set(imageView) {
            _placeImage = imageView
        }
    }
    
    var _placeImage: UIImageView = UIImageView()
    
    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        height = {
            return 200.0
        }
        
        addSubview(_placeImage)
        _placeImage.translatesAutoresizingMaskIntoConstraints = false

        addConstraint(
            NSLayoutConstraint(
                item: _placeImage,
                attribute: .CenterX,
                relatedBy: .Equal,
                toItem: self,
                attribute: .CenterX,
                multiplier: 1.0,
                constant: 0.0))
        
        
        addConstraint(
            NSLayoutConstraint(
                item: _placeImage,
                attribute: .CenterY,
                relatedBy: .Equal,
                toItem: self,
                attribute: .CenterY,
                multiplier: 1.0,
                constant: 0.0))
    }
    
    override func setup() {
        super.setup()
        selectionStyle = .None
    }
    
    override func update() {
        super.update()
    }
    
    func valueChanged() {
    }
}
