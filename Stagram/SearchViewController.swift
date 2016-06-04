//
//  SearchViewController.swift
//  Stagram
//
//  Created by Dongri Jin on 3/20/16.
//  Copyright © 2016 Dongri Jin. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class SearchViewController: ViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var tableView: UITableView!
    var request: NSURLRequest? = nil
    private var searchBar: UISearchBar!
    private var segmentedControl = UISegmentedControl(items: ["Tag","User"])
    let searchBarHeight = CGFloat(50)
    let segmentedHeight = CGFloat(30)
    let marginHeight    = CGFloat(5)
    var data: [JSON] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Search"
        self.view.backgroundColor = UIColor.whiteColor()

        let viewframe = view.frame
        let navigationBarHeight = navigationController?.navigationBar.frame.size.height
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height

        searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.frame = CGRectMake(0, 0, viewframe.size.width, searchBarHeight)
        searchBar.layer.position = CGPoint(x: self.view.bounds.width/2, y: navigationBarHeight! * 2)
        searchBar.searchBarStyle = UISearchBarStyle.Default
        searchBar.barStyle = UIBarStyle.Default
        searchBar.placeholder = "Keyword"
        self.view.addSubview(searchBar)
        let searchBarBottom = searchBar.frame.origin.y + searchBar.frame.size.height
        
        segmentedControl.frame = CGRectMake(8, marginHeight + searchBarBottom, viewframe.size.width-2*8, segmentedHeight)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = UIColor.whiteColor()
        segmentedControl.tintColor =  UIColor(white: 0.8, alpha: 1.0)
        segmentedControl.addTarget(self, action: #selector(SearchViewController.valueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.view.addSubview(segmentedControl)
        let segmentedBottom = segmentedControl.frame.origin.y + segmentedControl.frame.size.height
        
        let adjustHeight = CGFloat(2)
        let tableHeight = viewframe.height-segmentedBottom-statusBarHeight-navigationBarHeight!+marginHeight+adjustHeight
        let tableViewFrame = CGRectMake(0, marginHeight + adjustHeight + segmentedBottom, viewframe.size.width, tableHeight)
        tableView = UITableView()
        tableView.frame = tableViewFrame
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func doSearch() {
        if(segmentedControl.selectedSegmentIndex == 0){
            search(Instagram.searchTag(searchBar.text!))
        } else if(segmentedControl.selectedSegmentIndex == 1){
            search(Instagram.searchUser(searchBar.text!))
        } else {
            search(Instagram.searchTag(searchBar.text!))
        }
    }

    // Mark search bar

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.view.endEditing(true)
        self.doSearch()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText == "") {
            self.data = []
            self.tableView.reloadData()
        }
    }
    
    // Mark segmented controll

    func valueChanged(segmentedControl: UISegmentedControl) {
        self.view.endEditing(true)
        if searchBar.text == "" {
            return
        }
        self.doSearch()
    }
    
    // Mark tableview

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")! as UITableViewCell;
        let result = self.data[indexPath.row].dictionaryValue
        if (segmentedControl.selectedSegmentIndex == 0) {
            let tag = result["name"]!.stringValue
            cell.textLabel?.text = "#\(tag)"
        }
        if (segmentedControl.selectedSegmentIndex == 1) {
            let username = result["username"]!.stringValue
            cell.textLabel?.text = "@\(username)"
        }
        return cell;
    }
    
    func tableView(table: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        let result = self.data[indexPath.row].dictionaryValue
        let viewerViewController = ResultViewController()
        if (segmentedControl.selectedSegmentIndex == 0) {
            let tag = result["name"]!.stringValue
            viewerViewController.searchTitle = "#\(tag)"
            viewerViewController.request = Instagram.recentTag(tag)
        }
        if (segmentedControl.selectedSegmentIndex == 1) {
            let username = result["username"]!.stringValue
            let id = result["id"]!.stringValue
            viewerViewController.searchTitle = "@\(username)"
            viewerViewController.request = Instagram.recentUser(id)
        }
        self.navigationController?.pushViewController(viewerViewController, animated: true)
        tableView?.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // Mark Search

    func search(request: NSURLRequest?) {
        Alamofire.request(.GET, request!, parameters: nil).responseJSON { response in
            switch response.result {
            case .Success:
                if let jsonObject = response.result.value {
                    let json = JSON(jsonObject)
                    if (json["meta"]["code"].intValue  == 200) {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                            self.data = json["data"].arrayValue
                            dispatch_async(dispatch_get_main_queue()) {
                                self.tableView!.reloadData()
                            }
                        }
                    }
                }
            case .Failure( _):
                print("Failure!!!")
            }
        }
    }
    
    // MARK rotated

    override func rotatedViews() {
        let viewframe = self.view.frame
        let navigationBarHeight = navigationController?.navigationBar.frame.size.height
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        
        searchBar.frame = CGRectMake(0, viewframe.origin.y, viewframe.size.width, searchBarHeight)
        searchBar.layer.position = CGPoint(x: self.view.bounds.width/2, y: navigationBarHeight! * 2)
        let searchBarBottom = searchBar.frame.origin.y + searchBar.frame.size.height
        
        segmentedControl.frame = CGRectMake(8, marginHeight + searchBarBottom, viewframe.size.width-2*8, segmentedHeight)
        let segmentedBottom = segmentedControl.frame.origin.y + segmentedControl.frame.size.height
        
        let adjustHeight = CGFloat(2)
        let tableHeight = viewframe.height-segmentedBottom-statusBarHeight-navigationBarHeight!+marginHeight+adjustHeight
        let tableViewFrame = CGRectMake(0, marginHeight + adjustHeight + segmentedBottom, viewframe.size.width, tableHeight)
        tableView.frame = tableViewFrame
        tableView.reloadData()
    }

    
}
