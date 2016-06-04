//
//  PopularViewController.swift
//  Stagram
//
//  Created by Dongri Jin on 3/19/16.
//  Copyright © 2016 Dongri Jin. All rights reserved.
//

import Foundation
import UIKit

class PopularViewController: PhotosViewController {

    var request: NSURLRequest? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Popular"
        self.collectionView.backgroundColor = UIColor.whiteColor()

        if Instagram.loggedin() {
            request = Instagram.popular()
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

    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + view.frame.size.height > scrollView.contentSize.height * 0.8) {
            requestPhotos(self.request)
        }
    }

    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let footerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: PhotoLoadingIdentifier, forIndexPath: indexPath) as! PhotoCollectionViewLoading
        if self.photos.count > 0 {
            footerView.spinner.startAnimating()
        }
        return footerView
    }

}
