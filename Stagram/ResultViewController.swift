//
//  SearchResultViewController.swift
//  Stagram
//
//  Created by Dongri Jin on 3/27/16.
//  Copyright © 2016 Dongri Jin. All rights reserved.
//

import Foundation
import UIKit

class ResultViewController: PhotosViewController {

    var request: NSURLRequest?
    var searchTitle: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = searchTitle
        self.collectionView.backgroundColor = UIColor.whiteColor()
        requestPhotos(request)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
