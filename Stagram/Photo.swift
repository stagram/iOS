//
//  ResponsePhoto.swift
//  Stagram
//
//  Created by Dongri Jin on 3/20/16.
//  Copyright © 2016 Dongri Jin. All rights reserved.
//

import Foundation

class Photo: NSObject {
    
    var smallImageURL: NSURL
    var bigImageURL: NSURL
    
    init(smallImageURL: NSURL, bigImageURL: NSURL) {
        self.smallImageURL = smallImageURL
        self.bigImageURL = bigImageURL
        super.init()
    }
    
    func SmallImageURL() -> NSURL! {
        return smallImageURL
    }

    func BigImageURL() -> NSURL! {
        return bigImageURL
    }

}
