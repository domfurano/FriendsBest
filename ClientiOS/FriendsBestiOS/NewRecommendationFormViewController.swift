//
//  NewRecommendationFormViewController.swift
//  FriendsBest
//
//  Created by Dominic Furano on 4/5/16.
//  Copyright © 2016 Dominic Furano. All rights reserved.
//

import Eureka


class NewRecommendationFormViewController: FormViewController {
    var userRecommendation: UserRecommendation!
    
    convenience init(recommendation: UserRecommendation) {
        self.init()
        self.userRecommendation = recommendation
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
                switch self.userRecommendation.type! {
                case .TEXT:
                    break
                case .URL:
                    $0.value = self.userRecommendation.detail!
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
                if self.userRecommendation.tags != nil && self.userRecommendation.tags!.count > 0 {
                    $0.value = self.userRecommendation!.tags!.joinWithSeparator("")
                    //                    $0.disabled = true
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
        let values: [String: Any?] = form.values(includeHidden: false)
        
        if values["detail"] == nil || values["detail"]! == nil || (values["detail"]!! as! String).isEmpty ||
            values["keywords"] == nil || values["keywords"]! == nil || (values["keywords"]!! as! String).isEmpty {
            return
        }
        
        userRecommendation.detail = (values["detail"]!! as! String)
        userRecommendation.tags = (values["keywords"]!! as! String).componentsSeparatedByString(" ")
        userRecommendation.comments = values["comments"] == nil ? "" : (values["comments"]!! as! String)
        
        FBNetworkDAO.instance.postNewRecommendtaion(userRecommendation)
        
        for vc in (navigationController?.viewControllers)! {
            if vc.isKindOfClass(MainScreenViewController) {
                navigationController?.popToViewController(vc, animated: true)
                break
            }
        }
    }
    
}
