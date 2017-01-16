//
//  Comment.swift
//  HackerNews
//
//  Created by Shruthi Vinjamuri on 12/10/16.
//  Copyright © 2016 Shruthi Vinjamuri. All rights reserved.
//

import UIKit

class Comment {
    let commentId: Int
    let author: String
    let text: String
    var depth: Int = 0
    let createdDate: Date
    let replies: [Int]
    let isDeleted: Bool
    
    init(Id: Int, author: String, text: String, created: Date, deleted: Bool, replies: [Int]) {
        self.commentId = Id
        self.author = author
        self.text = text
        self.createdDate = created
        self.isDeleted = deleted
        self.replies = replies
    }
}

class NestedComments {
    var comment: Comment
    var children : [NestedComments]
    
    init(comment: Comment) {
        self.comment = comment
        self.children = [NestedComments]()
    }
}

