//
//  NotificationViewModel.swift
//  InstagramFireStoreTutorial
//
//  Created by 강호성 on 2021/05/02.
//

import UIKit

struct NotificationViewModel {
    private let notification: Notification
    
    init(notification: Notification) {
        self.notification = notification
    }
    
    var postImageUrl: URL? { return URL(string: notification.postImageUrl ?? "") }
    
    var profileImageUrl: URL? { return URL(string: notification.userProfileImageUrl) }
}
