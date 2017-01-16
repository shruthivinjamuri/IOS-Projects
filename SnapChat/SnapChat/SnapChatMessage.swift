//
//  SnapChatMessage.swift
//  SnapChat
//
//  Created by Shruthi Vinjamuri on 11/12/16.
//  Copyright © 2016 Shruthi Vinjamuri. All rights reserved.
//

import UIKit
import Foundation

class SnapChatMessage {
    var isOpened: Bool = false
    var description: String
    var timeStamp: String = ""
    var displayDuration: Int
    
    
    init(description: String, duration: Int) {
        self.description = description
        self.displayDuration = duration
        self.timeStamp = self.getTimeStamp()
    }
    
    fileprivate func getTimeStamp() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: Date())
    }
    
    internal func openMessage() {
        self.isOpened = true
        self.timeStamp = self.getTimeStamp()
    }
    
    internal func getStatusMessage() -> String {
        var status = ""
        if self.isOpened {
            status = self.displayDuration > 0 ? "Opened " : "Viewed "
        }
        else {
            status = "Delivered "
        }
        return "\(status) \(self.timeStamp)"
    }
    
//    internal func getImage() -> UIImage {
//        return isOpened ? UIImage(named: "viewed.png")! : UIImage(named: "received.png")!
//    }
    
    internal func getImage() -> UIImage {
        return isOpened ? (displayDuration > 0 ? UIImage(named: "half-received.png")!: UIImage(named: "viewed.png")!)
            : UIImage(named: "received.png")!
    }
    
}
