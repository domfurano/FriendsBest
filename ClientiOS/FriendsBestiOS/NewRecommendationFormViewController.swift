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
    
    override func loadView() {
        view = NewRecommendationFormView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.separatorStyle = .None
        
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
        
        form = Section() {
            $0.tag = "placeImageSection"
            $0.hidden = true
            }
            <<< PlaceImageRow() {
                $0.tag = "placeImageRow"
            }
            +++ Section("Recommendation")
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
//                    if self.userRecommendation.placeName != nil {
//                        $0.value = self.userRecommendation.placeName!
//                    } else {
//                    }
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
                
                }.cellUpdate({ (cell, row) in
//                    cell.textField.autocorrectionType = .No
                    cell.textField.autocapitalizationType = .None
//                    if self.userRecommendation.tagString != nil && !self.userRecommendation.tagString!.isEmpty {
//                        cell.textField.attributedText = self.attributedStringForTags(self.userRecommendation!.tagString!)
//                    } else if self.userRecommendation.tags != nil && self.userRecommendation.tags!.count > 0 {
//                        cell.textField.attributedText = self.attributedStringForTags(self.userRecommendation!.tags!)
////                        $0.value = self.userRecommendation!.tags!.joinWithSeparator(" ")
//                    }
                }).onChange({ (row: TextRow) in
//                    if self.lastString == nil {
//                        self.lastString = row.cell.textField.text
//                        return
//                    }
//                    if let text = row.cell.textField.text {
//                        if let last = text.characters.last {
//                            if last == " " {
//                                row.cell.textField.attributedText = self.attributedStringForTags(text)
//                            }
//                        }
//                    }
                })
            +++ Section("Comments")
            <<< TextAreaRow() {
                $0.tag = "comment"
                if self.newRecommendation.comments != nil {
                    $0.value = self.newRecommendation.comments
                }
        }
        
        if newRecommendation.type! == .place {
            //            let row: PlaceImageRow = self.form.rowByTag("placeImageRow")!
            GMSPlacesClient.sharedClient().lookUpPlaceID(newRecommendation.detail!, callback: { (place: GMSPlace?, error: NSError?) in
                if error != nil {
                    return
                }
                if let place = place {
                    self.form.rowByTag("detail")!.value = place.name
                    self.tableView!.reloadData()
                }
            })
            //            loadFirstPhotoForPlace(userRecommendation.detail!, row: row)
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
        
        FBNetworkDAO.instance.postNewRecommendtaion(newRecommendation, callback: nil)
        
        for vc in (navigationController?.viewControllers)! {
            if vc.isKindOfClass(MainScreenViewController) {
                navigationController?.popToViewController(vc, animated: true)
                break
            }
        }
    }
    
    func loadFirstPhotoForPlace(placeID: String, row: PlaceImageRow) {
        GMSPlacesClient.sharedClient()
            .lookUpPhotosForPlaceID(placeID) { (photos, error) -> Void in
                if let error = error {
                    NSLog("Error: \(error.description)")
                } else {
                    if let firstPhoto = photos?.results.first {
                        self.loadImageForMetadata(firstPhoto, row: row)
                    }
                }
        }
    }
    
    func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata, row: PlaceImageRow) {
        GMSPlacesClient.sharedClient()
            .loadPlacePhoto(photoMetadata,
                            constrainedToSize: row.cell.bounds.size,
                            scale: 1.0) {
                                (photo, error) -> Void in
                                if let error = error {
                                    NSLog("Error: \(error.description)")
                                } else {
                                    row.cell.placeImage.image = photo;
                                    let placeImageSection: Section = self.form.sectionByTag("placeImageSection")!
                                    placeImageSection.hidden = false
                                    self.tableView!.reloadData()
                                    NSLog("Picture found!")
                                    //                                    self.attributionTextView.attributedText = photoMetadata.attributions;
                                }
        }
    }
    
    private func attributedStringForTags(tagString: String) -> NSAttributedString {
        return attributedStringForTags(tagString.componentsSeparatedByString(" "))
    }
    
    private func attributedStringForTags(tagArray: [String]) -> NSAttributedString {
        let returnString: NSMutableAttributedString = NSMutableAttributedString()
        
        let attributes: [String : AnyObject] = [
            NSForegroundColorAttributeName: UIColor.blackColor(),
            NSBackgroundColorAttributeName: UIColor.colorFromHex(0xEDEDED),
            NSFontAttributeName: UIFont(name: "Proxima Nova Cond", size: 16.0)!
        ]
        
        let space = NSAttributedString(string: "  ")
        
        for tag in tagArray {
            let strippedTag = tag.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: " \n\t"))
            if !strippedTag.isEmpty {
                returnString.appendAttributedString(NSAttributedString(string: "  \(tag)  ", attributes: attributes))
                returnString.appendAttributedString(space)
            }
        }
        
        return returnString
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
        
        //        addConstraint(
        //            NSLayoutConstraint(
        //                item: _placeImage,
        //                attribute: .Width,
        //                relatedBy: .Equal,
        //                toItem: self,
        //                attribute: .Width,
        //                multiplier: 1.0,
        //                constant: 0.0))
        //
        //        addConstraint(
        //            NSLayoutConstraint(
        //                item: _placeImage,
        //                attribute: .Height,
        //                relatedBy: .Equal,
        //                toItem: self,
        //                attribute: .Height,
        //                multiplier: 1.0,
        //                constant: 0.0))
        
        
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

class NewRecommendationFormView: UITableView {
    override func drawRect(rect: CGRect) {
        let context: CGContext = UIGraphicsGetCurrentContext()!
        CGContextClearRect(context, bounds)
        
        CommonUI.drawGradientForContext(
            [
                CommonUI.topGradientColor,
                CommonUI.bottomGradientColor
            ],
            frame: self.bounds,
            context: context
        )
    }
}
