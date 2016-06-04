//
//  LoadingProxy.swift
//  Stagram
//
//  Created by Dongri Jin on 3/26/16.
//  Copyright © 2016 Dongri Jin. All rights reserved.
//

import UIKit

struct LoadingProxy{
    
    static var myActivityIndicator: UIActivityIndicatorView!
    
    static func set(v:UIViewController){
        self.myActivityIndicator = UIActivityIndicatorView()
        self.myActivityIndicator.frame = CGRectMake(0, 0, 100, 100)
        self.myActivityIndicator.center = v.view.center
        self.myActivityIndicator.hidesWhenStopped = false
        self.myActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        self.myActivityIndicator.backgroundColor = UIColor.clearColor()
        self.myActivityIndicator.layer.masksToBounds = true
        self.myActivityIndicator.layer.cornerRadius = 5.0;
        self.myActivityIndicator.layer.opacity = 0.8;
        v.view.addSubview(self.myActivityIndicator);
        self.off();
    }
    static func on(){
        myActivityIndicator.startAnimating();
        myActivityIndicator.hidden = false;
    }
    static func off(){
        myActivityIndicator.stopAnimating();
        myActivityIndicator.hidden = true;
    }

}