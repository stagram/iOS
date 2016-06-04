//
//  PhotosViewController.swift
//  Stagram
//
//  Created by Dongri Jin on 3/20/16.
//  Copyright © 2016 Dongri Jin. All rights reserved.
//

import Foundation
import UIKit
import OAuthSwift
import SwiftyJSON
import Alamofire
import AlamofireImage
import Haneke

import SloppySwiper

class PhotosViewController: ViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var collectionView: UICollectionView!
    let refreshControl = UIRefreshControl()

    var user: User? = nil

    var photos = [Photo]()
    var populatingPhotos = false
    var nextURLRequest: NSURLRequest?

    let PhotoCellIdentifier = "PhotoCell"
    let PhotoLoadingIdentifier = "PhotoLoading"
    let PhotoHeaderIdentifier = "PhotoHeader"

    var LAYOUT_LIST = "List"
    var LAYOUT_GRID = "Grid"

    var currentLayout: String = ""

    let TagRetryButton = 1
    
    var swiper: SloppySwiper!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        currentLayout = LAYOUT_LIST
        let changeLayoutButton = UIBarButtonItem(title: currentLayout, style: .Plain, target: self, action: #selector(PhotosViewController.changePhontoLayout))
        self.navigationItem.rightBarButtonItem = changeLayoutButton
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func setupView() {
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: createLayout())

        
        collectionView!.registerClass(PhotoCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: PhotoCellIdentifier)

        collectionView!.registerClass(PhotoCollectionViewLoading.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: PhotoLoadingIdentifier)

        collectionView?.dataSource = self
        collectionView?.delegate = self

        self.view.addSubview(collectionView)

        refreshControl.tintColor = UIColor(white: 0.7, alpha: 0.5)
        let attributedString = NSMutableAttributedString(string:"Loading...")
        let range = NSMakeRange(0, attributedString.length)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(white: 0.7, alpha: 0.5) , range: range)
        refreshControl.attributedTitle = attributedString
        refreshControl.addTarget(self, action: #selector(PhotosViewController.refreshAction), forControlEvents: .ValueChanged)

        collectionView!.addSubview(refreshControl)
        
        LoadingProxy.set(self)
        LoadingProxy.on()
        
        let retryButton = createRetryButton()
        retryButton.hidden = true
        self.view.addSubview(retryButton)
    }
    
    func changePhontoLayout(){
        if (currentLayout == LAYOUT_LIST) {
            currentLayout = LAYOUT_GRID
        } else {
            currentLayout = LAYOUT_LIST
        }
        let offset = self.collectionView.contentOffset
        self.navigationItem.rightBarButtonItem?.title = currentLayout
        self.collectionView.setCollectionViewLayout(createLayout(), animated: false)
        self.collectionView.reloadData()
        self.collectionView.contentOffset = offset
    }
    
    func createLayout() -> UICollectionViewFlowLayout {
        var column = 1
        if (currentLayout == LAYOUT_GRID) {
            column = 1
        } else {
            if UI_USER_INTERFACE_IDIOM() == .Pad {
                if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)) {
                    column = 5
                } else {
                    column = 4
                }
            } else {
                column = 3
            }
        }
        let layout = UICollectionViewFlowLayout()
        let itemWidth = floor((view.bounds.size.width - CGFloat(column - 1)) / CGFloat(column))
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumInteritemSpacing = 1.0
        layout.minimumLineSpacing = 1.0
        layout.footerReferenceSize = CGSize(width: self.view.bounds.size.width, height: 100.0)
        return layout
    }
    
    func refreshAction() {
        nextURLRequest = nil
        refreshControl.beginRefreshing()
        self.photos.removeAll(keepCapacity: false)
        self.collectionView!.reloadData()
        refreshControl.endRefreshing()
    }

    func requestPhotos(request: NSURLRequest?){
        if populatingPhotos {
            return
        }
        populatingPhotos = true
        Alamofire.request(.GET, request!, parameters: nil).responseJSON { response in
            defer {
                self.populatingPhotos = false
            }
            LoadingProxy.off()
            switch response.result {
            case .Success:
                self.view.viewWithTag(self.TagRetryButton)?.hidden = true
                if let jsonObject = response.result.value {
                    let json = JSON(jsonObject)
                    if (json["meta"]["code"].intValue  == 200) {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                            if let urlString = json["pagination"]["next_url"].URL {
                                self.nextURLRequest = NSURLRequest(URL: urlString)
                            } else {
                                self.nextURLRequest = nil
                            }
                            let photoInfos = json["data"].arrayValue
                                .filter {
                                    $0["type"].stringValue == "image"
                                }.map({
                                    Photo(smallImageURL: $0["images"]["low_resolution"]["url"].URL!, bigImageURL: $0["images"]["standard_resolution"]["url"].URL!)
                                })
                            let lastItem = self.photos.count
                            self.photos.appendContentsOf(photoInfos)
                            let indexPaths = (lastItem..<self.photos.count).map { NSIndexPath(forItem: $0, inSection: 0) }
                            dispatch_async(dispatch_get_main_queue()) {
                                self.collectionView!.insertItemsAtIndexPaths(indexPaths)
                            }
                        }
                    }
                }
            case .Failure( _):
                self.view.viewWithTag(self.TagRetryButton)?.hidden = false
            }
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (self.nextURLRequest != nil && scrollView.contentOffset.y + view.frame.size.height > scrollView.contentSize.height * 0.8) {
            requestPhotos(self.nextURLRequest)
        }
    }
    
    // MARK: CollectionView

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PhotoCellIdentifier, forIndexPath: indexPath) as! PhotoCollectionViewCell
        cell.imageView.image = nil
        let photo = photos[indexPath.row] as Photo
        cell.imageView.hnk_setImageFromURL(photo.BigImageURL(), placeholder: nil, format: nil, failure:
            { (error) -> () in
                print(error)
            }) { (image) -> () in
                cell.imageView.image = image
                cell.imageView.alpha = 0
                UIView.animateWithDuration(0.5, animations: {
                    cell.imageView.alpha = 1.0
                    cell.imageView.userInteractionEnabled = true
                    cell.imageView.layer.setValue(photo, forKey: "photoinfo")
                    cell.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PhotosViewController.imageTapped(_:))))
                })
            }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: PhotoHeaderIdentifier, forIndexPath: indexPath) as! PhotoCollectionViewHeader
            
            headerView.userName.text = self.user?.username
            headerView.fullName.text = self.user?.full_name
            headerView.bio.text = self.user?.bio
            headerView.website.text = self.user?.website
            if (self.user != nil) {
                Alamofire.request(.GET, NSURLRequest(URL: NSURL(string: (self.user?.profile_picture)!)!)).validate(contentType: ["image/*"]).responseImage {
                    response in
                    if let image = response.result.value {
                        headerView.userIcon.image = image
                    }
                }
                headerView.media.text = "\(self.user!.media)\nMedia"
                headerView.followers.text = "\(self.user!.followers)\nFollowers"
                headerView.followings.text = "\(self.user!.followings)\nFollowings"
            }
            return headerView
        case UICollectionElementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: PhotoLoadingIdentifier, forIndexPath: indexPath) as! PhotoCollectionViewLoading
            if nextURLRequest == nil {
                footerView.spinner.stopAnimating()
            } else {
                footerView.spinner.startAnimating()
            }
            return footerView
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    func imageTapped(sender: UITapGestureRecognizer) {
        let photoInfo = sender.view?.layer.valueForKey("photoinfo") as! Photo
        let viewerViewController = ViewerViewController()
        viewerViewController.respnosePhoto = photoInfo
        self.navigationController?.pushViewController(viewerViewController, animated: true)
        self.swiper = SloppySwiper(navigationController:self.navigationController)
        self.navigationController!.delegate = self.swiper;
        
    }
    
    func createRetryButton() -> UIButton {
        let button = UIButton()
        button.tag = TagRetryButton
        button.setTitle("Retry", forState: .Normal)
        button.setTitleColor(UIColor.grayColor(), forState: .Normal)
        button.frame = CGRectMake(0, 0, 300, 50)
        button.layer.position = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2)
        button.backgroundColor = UIColor(white: 0.9, alpha: 0.5)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGrayColor().CGColor
        button.setTitleColor(UIColor.blackColor(), forState: .Highlighted)
        button.addTarget(self, action: #selector(PhotosViewController.refreshAction), forControlEvents:.TouchUpInside)
        return button
    }

    
    override func rotatedViews() {
        if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)) {
            self.collectionView.frame = self.view.frame
            self.collectionView.setCollectionViewLayout(createLayout(), animated: false)
        }
        if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)) {
            self.collectionView.frame = self.view.frame
            self.collectionView.setCollectionViewLayout(createLayout(), animated: false)
        }
    }

}

class PhotoCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView()
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0.9, alpha: 0.5)
        imageView.frame = bounds
        addSubview(imageView)
    }
    override func prepareForReuse() {
        imageView.hnk_cancelSetImage()
        imageView.frame = bounds
        imageView.image = nil
    }

    internal override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        imageView.frame = bounds
    }
}

class PhotoCollectionViewLoading: UICollectionReusableView {
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        spinner.center = self.center
        addSubview(spinner)
        spinner.stopAnimating()
    }
}
