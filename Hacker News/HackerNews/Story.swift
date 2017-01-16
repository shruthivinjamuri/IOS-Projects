//
//  Story.swift
//  HackerNews
//
//  Created by Shruthi Vinjamuri on 12/10/16.
//  Copyright © 2016 Shruthi Vinjamuri. All rights reserved.
//

import UIKit

class Story {
    let storyId: Int
    let author: String
    let title: String
    let url: String
    let score: Int
    let commentIds: [Int]
    
    init(Id: Int, author: String, title: String, url: String, score: Int, comments: [Int]) {
        self.author = author
        self.storyId = Id
        self.commentIds = comments
        self.title = title
        self.score =  score
        self.url = url
    }
}
