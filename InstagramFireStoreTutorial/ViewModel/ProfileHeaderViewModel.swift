//
//  ProfileHeaderViewModel.swift
//  InstagramFireStoreTutorial
//
//  Created by 강호성 on 2021/04/22.
//

import Foundation

struct ProfileHeaderViewModel {
    let user: User
    
    var fullname: String {
        return user.fullname
    }
    
    var profileImageUrl: URL? {
        return URL(string: user.profileImageUrl)
    }
    
    init(user: User) {
        self.user = user
    }
}
