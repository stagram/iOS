//
//  ViewerViewController.swift
//  Stagram
//
//  Created by Dongri Jin on 3/21/16.
//  Copyright © 2016 Dongri Jin. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage

class ViewerViewController: ViewController, UIScrollViewDelegate {
    
    let scrollView = UIScrollView()
    let imageView = UIImageView()
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    var respnosePhoto: Photo?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Viewer"
        self.view.backgroundColor = UIColor.whiteColor()
        setupView()
    }

    func setupView() {
        scrollView.frame = view.frame
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 2.0
        scrollView.zoomScale = 1.0
        view.addSubview(scrollView)
        
        LoadingProxy.set(self)
        LoadingProxy.on()

        imageView.contentMode = .ScaleAspectFill
        scrollView.addSubview(imageView)
        
        if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)) {
            let navigationBarHeight = navigationController?.navigationBar.frame.size.height
            let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
            let tabBarHeight = tabBarController?.tabBar.frame.size.height
            let height = scrollView.frame.size.height - navigationBarHeight! - statusBarHeight - tabBarHeight!
            self.imageView.frame = CGRectMake(0, 0, height, height)
        }
        if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)) {
            let width = scrollView.frame.size.width
            self.imageView.frame = CGRectMake(0, scrollView.frame.size.height/2 - width/2, width, width)
        }
        
        Alamofire.request(.GET, respnosePhoto!.BigImageURL()).validate(contentType: ["image/*"]).responseImage {
            response in
            if let image = response.result.value {
                self.imageView.image = image
                self.imageView.alpha = 0
                UIView.animateWithDuration(0.2, animations: {
                    self.imageView.alpha = 1.0
                    LoadingProxy.off()
                })
            }
        }
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewerViewController.handleDoubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTapRecognizer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        centerScrollViewContents()
    }
    
    // MARK: Gesture Recognizers
    
    func handleDoubleTap(recognizer: UITapGestureRecognizer!) {
        let pointInView = recognizer.locationInView(self.imageView)
        self.zoomInZoomOut(pointInView)
    }
    
    // MARK: ScrollView
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        self.centerScrollViewContents()
    }
    
    func centerScrollViewContents() {
        let boundsSize = scrollView.frame
        var contentsFrame = self.imageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - scrollView.scrollIndicatorInsets.top - scrollView.scrollIndicatorInsets.bottom - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        self.imageView.frame = contentsFrame
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func zoomInZoomOut(point: CGPoint!) {
        let newZoomScale = self.scrollView.zoomScale > (self.scrollView.maximumZoomScale/2) ? self.scrollView.minimumZoomScale : self.scrollView.maximumZoomScale
        
        let scrollViewSize = self.scrollView.bounds.size
        
        let width = scrollViewSize.width / newZoomScale
        let height = scrollViewSize.height / newZoomScale
        let x = point.x - (width / 2.0)
        let y = point.y - (height / 2.0)
        
        let rectToZoom = CGRect(x: x, y: y, width: width, height: height)
        
        self.scrollView.zoomToRect(rectToZoom, animated: true)
    }
    
    override func rotatedViews() {
        scrollView.frame = view.frame
        if(UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)) {
            let navigationBarHeight = navigationController?.navigationBar.frame.size.height
            let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
            let tabBarHeight = tabBarController?.tabBar.frame.size.height
            let height = scrollView.frame.size.height - navigationBarHeight! - statusBarHeight - tabBarHeight!
            self.imageView.frame = CGRectMake(0, 0, height, height)
        }
        if(UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation)) {
            let width = scrollView.frame.size.width
            self.imageView.frame = CGRectMake(0, scrollView.frame.size.height/2 - width/2, width, width)
        }
    }

}
