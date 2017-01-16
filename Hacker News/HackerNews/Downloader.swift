//
//  Downloader.swift
//  Hacker News Reader
//
//  Created by Eric Fritz on 8/28/16.
//  Copyright © 2016 Eric Fritz. All rights reserved.
//

import UIKit

func showNetworkIndicator(_ show: Bool) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = show
}

func parse<T>(_ url: URL) -> T? {
    if let rawData = try? Data(contentsOf: url) {
        if let deserialized = (try? JSONSerialization.jsonObject(with: rawData, options: JSONSerialization.ReadingOptions.mutableContainers)) as? T {
            return deserialized
        }
    }
    
    return nil
}

typealias DownloadHandler = (URL!) -> ()

class Wrapper<T> {
    let p: T
    
    init(_ p: T) {
        self.p = p
    }
}

class Downloader: NSObject, URLSessionDelegate {
    let config: URLSessionConfiguration
    lazy var session: Foundation.URLSession = {
        let queue = OperationQueue.main
        
        return Foundation.URLSession(
            configuration: self.config,
            delegate: self,
            delegateQueue: queue
        )
    }()
    
    init(configuration config: URLSessionConfiguration) {
        self.config = config
        super.init()
    }
    
    func download(_ path: String, completionHandler ch: DownloadHandler) -> URLSessionTask {
        let url = URL(string: path)!
        let req = NSMutableURLRequest(url: url)
        URLProtocol.setProperty(Wrapper(ch), forKey: "ch", in: req)
        let task = self.session.downloadTask(with: req as Foundation.URLRequest)
        task.resume()
        return task
    }
    
    func URLSession(_ session: Foundation.URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingToURL location: URL) {
        let req = downloadTask.originalRequest!
        let ch: AnyObject = URLProtocol.property(forKey: "ch", in: req)! as AnyObject
        let response = downloadTask.response as! HTTPURLResponse
        
        (ch as! Wrapper<DownloadHandler>).p(response.statusCode == 200 ? location : nil)
    }
    
    func cancelAllTasks() {
        self.session.invalidateAndCancel()
    }
}
