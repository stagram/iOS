//
//  UserInfo.swift
//  Stagram
//
//  Created by Dongri Jin on 4/11/16.
//  Copyright © 2016 Dongri Jin. All rights reserved.
//

import Foundation

class User: NSObject {
    
    var id: String = ""
    var username: String = ""
    var full_name: String = ""
    var profile_picture: String = ""
    var bio: String = ""
    var website: String = ""
    var media: Int64 = 0
    var followers: Int64 = 0
    var followings: Int64 = 0

    override init() {
        super.init()
    }
    
    func setID(id: String) {
        self.id = id
    }

    func usernaem(username: String) {
        self.username = username
    }

    func full_name(full_name: String) {
        self.full_name = full_name
    }

    func profile_picture(profile_picture: String) {
        self.profile_picture = profile_picture
    }

    func bio(bio: String) {
        self.bio = bio
    }
    
    func website(website: String) {
        self.website = website
    }
    
    func media(media: Int64) {
        self.media = media
    }
    
    func followers(followers: Int64) {
        self.followers = followers
    }

    func followings(followings: Int64) {
        self.followings = followings
    }

}
