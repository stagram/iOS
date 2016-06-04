//
//  Instagram.swift
//  Stagram
//
//  Created by Dongri Jin on 3/20/16.
//  Copyright © 2016 Dongri Jin. All rights reserved.
//

import Foundation
import OAuthSwift

class Instagram: NSObject {

    static let API_ENDPOINT    = "https://api.instagram.com/v1"
    static let AUTHORIZE_URL   = "https://api.instagram.com/oauth/authorize"
    static let CALLBACK_URL    = "stagram://oauth-callback"
    static let UD = NSUserDefaults.standardUserDefaults()

    static func clientInfo() -> NSDictionary {
        let filePath = NSBundle.mainBundle().pathForResource("Key.plist", ofType:nil )
        let dic = NSDictionary(contentsOfFile:filePath!)!
        let clientID = dic["ClientID"] as! String
        let clientSecret = dic["ClientSecret"] as! String
        if clientID == "" && clientSecret == ""  {
            print("✨✨✨✨✨ Key.plist is Empty. Please setting Key.plist ✨✨✨✨✨")
            print("ClientID and ClientSecret see https://www.instagram.com/developer/clients/manage/")
            return dic
        }
        return dic
    }

    static func login(){
        let info = clientInfo()
        let oauthswift = OAuth2Swift(
            consumerKey:    info["ClientID"] as! String,
            consumerSecret: info["ClientSecret"] as! String,
            authorizeUrl:   AUTHORIZE_URL,
            responseType:   "token"
        )
        oauthswift.authorize_url_handler = get_url_handler()
        let state: String = generateStateWithLength(20) as String
        oauthswift.authorizeWithCallbackURL( NSURL(string: CALLBACK_URL)!, scope: "likes+comments", state:state, success: {
            credential, response, parameters in
            Instagram.accessToken(credential.oauth_token)
            let n : NSNotification = NSNotification(name: "login", object: self, userInfo: nil)
            NSNotificationCenter.defaultCenter().postNotification(n)
            }, failure: { error in
                print(error.localizedDescription)
        })
    }

    static func popular() -> NSURLRequest {
        let urlString = "\(API_ENDPOINT)/media/popular?access_token=\(accessToken())"
        return NSURLRequest(URL: NSURL(string: urlString)!)
    }
    
    static func me() -> NSURLRequest {
        let urlString = "\(API_ENDPOINT)/users/self/media/recent?count=\(count())&access_token=\(accessToken())"
        return NSURLRequest(URL: NSURL(string: urlString)!)
    }
    
    static func feed() -> NSURLRequest {
        let urlString = "\(API_ENDPOINT)/users/self/feed?count=\(count())&access_token=\(accessToken())"
        return NSURLRequest(URL: NSURL(string: urlString)!)
    }
    
    static func search(q: String) -> NSURLRequest {
        let urlString = "\(API_ENDPOINT)/tags/\(q)/media/recent?count=\(count())&access_token=\(accessToken())"
        let url = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        return NSURLRequest(URL: NSURL(string: url!)!)
    }
    
    static func searchTag(q: String) -> NSURLRequest {
        let urlString = "\(API_ENDPOINT)/tags/search?q=\(q)&access_token=\(accessToken())"
        let url = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        return NSURLRequest(URL: NSURL(string: url!)!)
    }

    static func searchUser(q: String) -> NSURLRequest {
        let urlString = "\(API_ENDPOINT)/users/search?q=\(q)&access_token=\(accessToken())"
        let url = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        return NSURLRequest(URL: NSURL(string: url!)!)
    }

    static func recentTag(tag_name: String) -> NSURLRequest {
        let urlString = "\(API_ENDPOINT)/tags/\(tag_name)/media/recent/?count=\(count())&access_token=\(accessToken())"
        let url = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        return NSURLRequest(URL: NSURL(string: url!)!)
    }
    
    static func recentUser(user_id: String) -> NSURLRequest {
        let urlString = "\(API_ENDPOINT)/users/\(user_id)/media/recent/?count=\(count())&access_token=\(accessToken())"
        let url = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        return NSURLRequest(URL: NSURL(string: url!)!)
    }

    static func userSelf() -> NSURLRequest {
        let urlString = "\(API_ENDPOINT)/users/self/?access_token=\(accessToken())"
        let url = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        return NSURLRequest(URL: NSURL(string: url!)!)
    }

    static func accessToken() -> String {
        if UD.objectForKey("access_token") == nil {
            return ""
        }
        let access_token : String = UD.objectForKey("access_token") as! String
        return access_token
    }
    
    static func loggedin() -> Bool {
        if UD.objectForKey("access_token") == nil {
            return false
        }
        return true
    }
    
    static func accessToken(access_token: String) {
        UD.setObject(access_token, forKey: "access_token")
        UD.synchronize()
    }
    
    static func count() -> Int {
        return 30
    }
    
    static func get_url_handler() -> OAuthSwiftURLHandlerType {
        let url_handler = WebViewController()
        return url_handler
    }

}
