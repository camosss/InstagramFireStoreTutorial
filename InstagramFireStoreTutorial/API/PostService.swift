//
//  PostService.swift
//  InstagramFireStoreTutorial
//
//  Created by 강호성 on 2021/04/26.
//

import UIKit
import Firebase

struct PostService {
    
    static func uploadPost(caption: String, image: UIImage, user: User,
                           completion: @escaping(FireStoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        ImageUploader.uploadImage(image: image) { imageUrl in
            let data = ["caption": caption,
                        "timestamp": Timestamp(date: Date()),
                        "likes": 0,
                        "imageUrl": imageUrl,
                        "ownerUid": uid,
                        "ownerImageUrl": user.profileImageUrl,
                        "ownerUsername": user.username] as [String : Any]
            
            COLLECTION_POSTS.addDocument(data: data, completion: completion)
        }
    }
    
    static func fetchPosts(completion: @escaping([Post]) -> Void) {
        COLLECTION_POSTS.order(by: "timestamp", descending: true).getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else { return }
            
            let posts = documents.map({ Post(postId: $0.documentID, dictionary: $0.data()) })
            completion(posts)
        }
    }
    // 모든 post를 uid에 전달
    static func fetchPosts(forUser uid: String, completion: @escaping([Post]) -> Void) {
        let query = COLLECTION_POSTS.whereField("ownerUid", isEqualTo: uid)
        
        query.getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents else { return }
            
            var posts = documents.map({ Post(postId: $0.documentID, dictionary: $0.data()) })
            
            // (수정) profile에 올라온 순서에 맞게 정렬
            posts.sort { (post1, post2) -> Bool in
                return post1.timestamp.seconds > post2.timestamp.seconds
            }
            
            completion(posts)
        }
    }
    
    static func likePost(post: Post, completion: @escaping(FireStoreCompletion)) {
        // 현재 사용자이 id확보
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_POSTS.document(post.postId).updateData(["likes": post.likes + 1])
        
        COLLECTION_POSTS.document(post.postId).collection("post-likes").document(uid).setData([:]) { _ in
            COLLECTION_POSTS.document(uid).collection("user-likes").document(post.postId).setData([:], completion: completion)
        }
    }
    
    static func unlikePost(post: Post, completion: @escaping(FireStoreCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
//        guard post.likes > 0 else { return }
        
        COLLECTION_POSTS.document(post.postId).updateData(["likes": post.likes - 1])

        COLLECTION_POSTS.document(post.postId).collection("post-likes").document(uid).delete { _ in
            COLLECTION_POSTS.document(uid).collection("user-likes").document(post.postId).delete(completion: completion)
        }
    }
}
