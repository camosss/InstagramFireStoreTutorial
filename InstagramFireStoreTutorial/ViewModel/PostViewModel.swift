//
//  PostViewModel.swift
//  InstagramFireStoreTutorial
//
//  Created by 강호성 on 2021/04/26.
//

import Foundation

struct PostViewModel {
    private let post: Post
    
    var imageUrl: URL? { return URL(string: post.imageUrl) }
    
    var caption: String { return post.caption }
    
    var likes: Int { return post.likes }
    
    init(post: Post) {
        self.post = post
    }
}
