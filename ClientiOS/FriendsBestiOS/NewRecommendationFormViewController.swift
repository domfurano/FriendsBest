//
//  NewRecommendationFormViewController.swift
//  FriendsBest
//
//  Created by Dominic Furano on 4/5/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import Eureka


class NewRecommendationFormViewController: FormViewController {
    var type: RecommendationType?
    var detail: String?
    var tags: [String]?
    
    convenience init(type: RecommendationType, detail: String) {
        self.init()
        self.type = type
        self.detail = detail
    }
    
    convenience init(type: RecommendationType, detail: String, tags: [String]) {
        self.init()
        self.type = type
        self.detail = detail
        self.tags = tags
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
                switch self.type! {
                case .TEXT:
                    break
                case .URL:
                    $0.value = self.detail
                    $0.disabled = true
                    break
                case .PLACE:
                    break
                }
                }.cellSetup({ (cell, row) in
                })
            +++ Section("Keywords")
            <<< TextRow() {
                $0.tag = "keywords"
                if tags != nil {
                    $0.value = self.tags!.joinWithSeparator("")
                    $0.disabled = true
                }
            }
            +++ Section("Comments")
            <<< TextAreaRow() {
                $0.tag = "comment"
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
        if type != nil && detail != nil {
            let values: [String: Any?] = form.values(includeHidden: false)
            
            if values["keywords"] == nil || (values["keywords"]!! as! String).isEmpty {
                return
            }
            
            FBNetworkDAO.instance.postNewRecommendtaion(
                values["detail"]!! as! String,
                type: type!.rawValue,
                comments: values["comment"]!! as! String,
                recommendationTags: (values["keywords"]!! as! String).componentsSeparatedByString(" ")
            )
        }
    }
    
}
