//
//  CommentService.swift
//  InstagramFireStoreTutorial
//
//  Created by 강호성 on 2021/04/28.
//

import Firebase

struct CommentService {
    
    static func uploadComment(comment: String, postID: String, user: User,
                              completion: @escaping(FireStoreCompletion)) {
        
        let data: [String: Any] = ["uid": user.uid,
                                   "comment": comment,
                                   "timestamp":Timestamp(date: Date()),
                                   "username":user.username,
                                   "profileImageUrl": user.profileImageUrl]
        
        COLLECTION_POSTS.document(postID).collection("comments").addDocument(data: data,
                                                                             completion: completion)
    }
    
    static func fetchComments(forPost postID: String, completion: @escaping([Comment]) -> Void) {
        
        var comments = [Comment]()
        
        let query = COLLECTION_POSTS.document(postID).collection("comments")
            .order(by: "timestamp", descending: true)
        
        // - addSnapshotListener
        // 해당 comment를 수신한 다음 해당 comment를 기반으로 UI를 업데이트
        // API 호출을 수동으로 수행할 필요없이 데이터베이스에 추가되는 즉시
        // 새로운 comment가 데이터를 새로고침하기 위해 포스트하는 것과 같음
        query.addSnapshotListener { (snapshot, error) in  // snapshot을 보고
            snapshot?.documentChanges.forEach({ change in // 문서 변경사항(documentChanges)을 보고
                if change.type == .added {                // forEach문으로 반복해서 변경 유형이 추가되었는지 확인
                    let data = change.document.data()
                    let comment = Comment(dictionary: data)
                    comments.append(comment)
                }
            })
            completion(comments)
        }
    }
}
