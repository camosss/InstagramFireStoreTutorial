//
//  CommentController.swift
//  InstagramFireStoreTutorial
//
//  Created by 강호성 on 2021/04/27.
//

import UIKit

private let reuseIdentifier = "CommentCell"

class CommentController: UICollectionViewController {
    
    // MARK: - Properties
    
    private let post: Post
    private var comments = [Comment]()
    
    private lazy var commentInputView: CommentInputAccesoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let cv = CommentInputAccesoryView(frame: frame)
        cv.delegate = self
        return cv
    }()
    
    // MARK: - Lifecycle
    
    init(post: Post) {
        self.post = post
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetchComments()
    }
    
    override var inputAccessoryView: UIView? {
        get { return commentInputView }
    }
    
    // 키보드를 숨기고 표시하고 이동하는 기능
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - API
    
    func fetchComments() {
        CommentService.fetchComments(forPost: post.postId) { comments in
            self.comments = comments
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Helpers
    
    func configureCollectionView() {
        navigationItem.title = "Comments"
        
        collectionView.backgroundColor = .white
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        // drag할 때 키보드 창이 내려가도록
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
    }
}
    // MARK: - UICollectionViewDataSource
    
extension CommentController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
        
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CommentCell
        cell.viewModel = CommentViewModel(comment: comments[indexPath.row])
        return cell
    }
}

    // MARK: - UICollectionViewDelegateFlowLayout

extension CommentController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewModel = CommentViewModel(comment: comments[indexPath.row])
        let height = viewModel.size(forWidh: view.frame.width).height + 32
        return CGSize(width: view.frame.width, height: height)
    }
}

    // MARK: - CommentInputAccesoryViewDelegate
extension CommentController: CommentInputAccesoryViewDelegate {
    func inputView(_ inputView: CommentInputAccesoryView, wantsToUploadComment comment: String) {
        //     print("DEBUG: Comment is \(comment)")
        guard let tab = tabBarController as? MainTabController else { return }
        guard let user = tab.user else { return }
        
        showLoader(true)
        
        CommentService.uploadComment(comment: comment, postID: post.postId, user: user) { error in
            self.showLoader(false)
            inputView.clearCommentTextView()
        }
    }
}
