//
//  MeViewController.swift
//  Stagram
//
//  Created by Dongri Jin on 3/21/16.
//  Copyright © 2016 Dongri Jin. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class MeViewController: PhotosViewController {
    
    var photosRequest: NSURLRequest? = nil
    var userSelfRequest: NSURLRequest? = nil

    var populatingUserSelf = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Me"
        self.collectionView.backgroundColor = UIColor.whiteColor()
        
        collectionView!.registerClass(PhotoCollectionViewHeader.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: PhotoHeaderIdentifier)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MeViewController.update(_:)), name: "login", object: nil)
        
        if Instagram.loggedin() {
            photosRequest = Instagram.me()
            requestPhotos(photosRequest)
            userSelfRequest = Instagram.userSelf()
            requestUserSelf(userSelfRequest)
        } else {
            LoadingProxy.off()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func refreshAction() {
        super.refreshAction()
        self.requestPhotos(self.photosRequest)
        self.requestUserSelf(self.userSelfRequest)
    }

    func update(notification: NSNotification)  {
        self.collectionView.backgroundColor = UIColor.whiteColor()
        photosRequest = Instagram.me()
        requestPhotos(photosRequest)
        userSelfRequest = Instagram.userSelf()
        requestUserSelf(userSelfRequest)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let size = CGSize(width: self.view.frame.width, height: 185)
        return size
    }
    
    func requestUserSelf(request: NSURLRequest?){
        if populatingUserSelf {
            return
        }
        populatingUserSelf = true
        Alamofire.request(.GET, request!, parameters: nil).responseJSON { response in
            defer {
                self.populatingUserSelf = false
            }
            LoadingProxy.off()
            switch response.result {
            case .Success:
                self.view.viewWithTag(self.TagRetryButton)?.hidden = true
                if let jsonObject = response.result.value {
                    let json = JSON(jsonObject)
                    if (json["meta"]["code"].intValue  == 200) {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                            let userValue = json["data"].dictionaryValue
                            self.user = User()
                            self.user!.id = userValue["id"]!.string!
                            self.user!.username = userValue["username"]!.string!
                            self.user!.full_name = userValue["full_name"]!.string!
                            self.user!.profile_picture = userValue["profile_picture"]!.string!
                            self.user!.bio = userValue["bio"]!.string!
                            self.user!.website = userValue["website"]!.string!
                            let counts = userValue["counts"]?.dictionaryValue
                            self.user!.media = counts!["media"]!.int64!
                            self.user!.followers = counts!["followed_by"]!.int64!
                            self.user!.followings = counts!["follows"]!.int64!
                            dispatch_async(dispatch_get_main_queue()) {
                                self.collectionView.reloadSections(NSIndexSet(index: 0))
                            }
                        }
                    }
                }
            case .Failure( _):
                self.view.viewWithTag(self.TagRetryButton)?.hidden = false
            }
        }
    }


}


class PhotoCollectionViewHeader: UICollectionReusableView {
    let userIcon = UIImageView()
    let userName = UILabel()
    let fullName = UILabel()
    let bio = UILabel()
    let website = UILabel()
    let media = UILabel()
    let followers = UILabel()
    let followings = UILabel()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
        
        let margin: CGFloat = 10
        let iconWidth: CGFloat = 80
        let iconHeight: CGFloat = 80
        
        userIcon.frame = CGRectMake(margin, margin, iconWidth, iconHeight)
        userIcon.image = nil
        userIcon.layer.cornerRadius = 5
        userIcon.clipsToBounds = true;
        self.addSubview(userIcon)
        
        let labelWidth: CGFloat = 300
        let labelHeight: CGFloat = 20
        let labelMargin: CGFloat = 5

        userName.frame = CGRectMake(userIcon.right() + margin, margin, labelWidth, labelHeight)
        userName.text = ""
        self.addSubview(userName)
        
        
        fullName.frame = CGRectMake(userIcon.right() + margin, userName.bottom() + labelMargin, labelWidth, labelHeight)
        fullName.text = ""
        self.addSubview(fullName)
        
        bio.frame = CGRectMake(userIcon.right() + margin, fullName.bottom() + labelMargin, labelWidth, labelHeight)
        bio.text = ""
        self.addSubview(bio)
        
        website.frame = CGRectMake(userIcon.right() + margin, bio.bottom() + labelMargin, labelWidth, labelHeight)
        website.text = ""
        self.addSubview(website)
        
        let width = self.width()
        let blockMargin: CGFloat = 10
        let blockHeight: CGFloat = 60
        let blockTop = website.bottom() + blockMargin
        let blockWidth = (width - blockMargin * 4) / 3
        
        let blockColor = UIColor(white: 0.8, alpha: 0.5)
        
        media.frame = CGRectMake(margin, blockTop, blockWidth, blockHeight)
        media.backgroundColor = blockColor
        media.textAlignment = .Center
        media.numberOfLines = 0;
        media.layer.cornerRadius = 5
        media.clipsToBounds = true;
        media.text = ""
        self.addSubview(media)
        
        followers.frame = CGRectMake(media.right() + blockMargin, blockTop, blockWidth, blockHeight)
        followers.backgroundColor = blockColor
        followers.textAlignment = .Center
        followers.numberOfLines = 0;
        followers.layer.cornerRadius = 5
        followers.clipsToBounds = true;
        followers.text = ""
        self.addSubview(followers)
        
        followings.frame = CGRectMake(followers.right() + blockMargin, blockTop, blockWidth, blockHeight)
        followings.backgroundColor = blockColor
        followings.textAlignment = .Center
        followings.numberOfLines = 0;
        followings.layer.cornerRadius = 5
        followings.clipsToBounds = true;
        followings.text = ""
        self.addSubview(followings)

    }
}
