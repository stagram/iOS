//
//  FeedViewController.swift
//  Stagram
//
//  Created by Dongri Jin on 3/20/16.
//  Copyright © 2016 Dongri Jin. All rights reserved.
//

import Foundation
import UIKit

class FeedViewController: PhotosViewController {
    
    var request: NSURLRequest? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Feed"
        self.collectionView.backgroundColor = UIColor.whiteColor()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FeedViewController.update(_:)), name: "login", object: nil)

        if Instagram.loggedin() {
            request = Instagram.feed()
            requestPhotos(request)
        } else {
            LoadingProxy.off()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func refreshAction() {
        super.refreshAction()
        self.requestPhotos(self.request)
    }
    
    func update(notification: NSNotification)  {
        self.collectionView.backgroundColor = UIColor.whiteColor()
        self.view.viewWithTag(1)!.removeFromSuperview()
        request = Instagram.feed()
        requestPhotos(request)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
