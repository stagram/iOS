//
//  MainTabBarController.swift
//  Stagram
//
//  Created by Dongri Jin on 3/19/16.
//  Copyright © 2016 Dongri Jin. All rights reserved.
//

import Foundation
import UIKit

class MainTabBarController: UITabBarController {
    
    var tabPopular: UINavigationController!
    var tabSearch: UINavigationController!
    var tabFeed: UINavigationController!
    var tabMe: UINavigationController!

    override func viewDidLoad() {
        super.viewDidLoad()

        tabMe = UINavigationController(rootViewController: MeViewController())
        tabFeed = UINavigationController(rootViewController: FeedViewController())
        tabPopular = UINavigationController(rootViewController: PopularViewController())
        tabSearch = UINavigationController(rootViewController: SearchViewController())
        
        tabMe.tabBarItem = UITabBarItem(title: "Me", image: UIImage(named: "tab_me.png"), tag: 1)
        tabFeed.tabBarItem = UITabBarItem(title: "Feed", image: UIImage(named: "tab_feed.png"), tag: 2)
        tabPopular.tabBarItem = UITabBarItem(title: "Popular", image: UIImage(named: "tab_popular.png"), tag:3)
        tabSearch.tabBarItem = UITabBarItem(title: "Search", image: UIImage(named: "tab_search.png"), tag: 4)
        
        let tabs = NSArray(objects: tabMe!, tabFeed!, tabPopular!, tabSearch!)

        self.setViewControllers(tabs as? [UIViewController], animated: false)
    }
}
