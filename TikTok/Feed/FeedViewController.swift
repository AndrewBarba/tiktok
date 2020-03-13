//
//  FeedViewController.swift
//  TikTok
//
//  Created by Nidhi Kulkarni on 3/11/20.
//  Copyright © 2020 Nidhi Kulkarni. All rights reserved.
//

import UIKit
import AVFoundation
import Parse
import AlamofireImage
import AsyncDisplayKit

class FeedViewController: UIViewController, UIScrollViewDelegate {
    
    var tableNode: ASTableNode!
    var posts : [PFObject] = []
    var lastNode: PostNode?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        navigationItem.title = "Feed"
        self.tableNode = ASTableNode(style: .plain)
        self.wireDelegates()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.insertSubview(tableNode.view, at: 0)
        //        self.view.addSubnode(tableNode)
        self.applyStyle()
        self.tableNode.leadingScreensForBatching = 1.0;  // overriding default of 2.0
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.tableNode.frame = self.view.bounds;
    }
    
    
    func applyStyle() {
        self.view.backgroundColor = .systemPink
        self.tableNode.view.separatorStyle = .singleLine
        self.tableNode.view.isPagingEnabled = true
        
    }
    
    func wireDelegates() {
        self.tableNode.delegate = self
        self.tableNode.dataSource = self
    }
    
    
}

extension FeedViewController: ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let post = self.posts[indexPath.row]
        return {
            let node = PostNode(with: post)
            node.debugName = "Node \(indexPath.row)"

            return node
        }
    }
    
}

extension FeedViewController: ASTableDelegate {
    func tableNode(_ tableNode: ASTableNode, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        let width = UIScreen.main.bounds.size.width;
        let min = CGSize(width: width, height: (UIScreen.main.bounds.size.height/3) * 2);
        let max = CGSize(width: width, height: .infinity);
        return ASSizeRangeMake(min, max);
    }
    
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        return true
    }
    
    func tableNode(_ tableNode: ASTableNode, willBeginBatchFetchWith context: ASBatchContext) {
        self.retrieveNextPageWithCompletion { (newPosts) in
            self.insertNewRowsInTableNode(newPosts: newPosts)
            context.completeBatchFetching(true)
        }
    }
}

extension FeedViewController {
    
    func retrieveNextPageWithCompletion( block: @escaping ([PFObject]) -> Void) {
        let query = PFQuery(className:"Post")
        query.order(byAscending:"createdAt")
        query.includeKey("asset")
        query.whereKey("status", equalTo: "ready")
        query.limit = 2
        query.skip = self.posts.count
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            } else if let objects = objects {
                print("Successfully retrieved \(objects.count) posts.")
                DispatchQueue.main.async {
                    block(objects)
                }
            }
        }
    }
    
    func insertNewRowsInTableNode(newPosts: [PFObject]) {
        guard newPosts.count > 0 else {
            return
        }
        let section = 0
        var indexPaths: [IndexPath] = []
        let total = self.posts.count + newPosts.count
        for row in self.posts.count...total-1 {
            let path = IndexPath(row: row, section: section)
            indexPaths.append(path)
        }
        self.posts.append(contentsOf: newPosts)
        self.tableNode.insertRows(at: indexPaths, with: .none)
        
    }
    
    
}

extension FeedViewController : RecordedVideoDelegate {
    
    func didUploadVideo(fileUrl: URL) {
        let model = PFObject(className: "Post")
        model["videoSrc"] = fileUrl.absoluteString
        self.posts.append(model)
        DispatchQueue.main.async {
            self.tableNode.reloadData()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "recordSegue" {
            guard let dest = segue.destination as? RecordViewController else { return }
                dest.delegate = self
            
        }
    }
}
