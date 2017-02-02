//
//  DirectoryTree.swift
//  GitHub
//
//  Created by Shruthi Vinjamuri on 12/17/16.
//  Copyright © 2016 UWM. All rights reserved.
//

import UIKit

import JSONJoy
import SwiftHTTP

class Directory {
    var path: String?
    var type: String?
    var sha: String?
    var size: Int?
    var url: String?
    
    required init(_ decoder: JSONDecoder) {
        self.path = decoder["path"].string
        self.type = decoder["type"].string
        self.sha = decoder["sha"].string
        if let blobSize = decoder["size"].integer {
            self.size = blobSize
        }
        self.url = decoder["url"].string
    }
    
    init(path: String, type: String, url: String) {
        self.path = path
        self.type = type
        self.url = url
    }
}

class DirectoryTree {
    var directory: Directory
    var children = [DirectoryTree]()
    
    init(directory: Directory) {
        self.directory = directory
    }
}

func setUpDirectories(_ decoder: JSONDecoder) -> [Directory] {
    var directories = [Directory]()
    if let decoderArray = decoder["tree"].array {
        for dir in decoderArray {
            directories.append(Directory(dir))
        }
    }
    else {
        directories.append(Directory(decoder["tree"]))
    }
    return directories
}

func loadDirectories(directories: [Directory], token: String, completionHandler: @escaping ([DirectoryTree?])->Void ) {
    
    if (directories.count == 0) {
        completionHandler([nil])
        return
    }
    var parentDirectoryTree = [DirectoryTree]()
    for dir in directories {
        if dir.type == "blob" {
             parentDirectoryTree.append(DirectoryTree(directory: dir))
            if parentDirectoryTree.count == directories.count {
                completionHandler(parentDirectoryTree)
            }
            continue
        }
        loadDirectory(url: dir.url!, token: token, completionHandler: { (status, childrenDirectories) in
            let directoryTree = DirectoryTree(directory: dir)
            if status {
                directoryTree.children = childrenDirectories.flatMap({ $0 }).sorted(by: { $0.directory.type! > $1.directory.type! }) }
            parentDirectoryTree.append(directoryTree)
            if parentDirectoryTree.count == directories.count {
                completionHandler(parentDirectoryTree)
            }
        })
    }
}

func loadBlobContent(url: String, token: String, completionHandler: @escaping (Bool, String?)->Void ) {

    do {
        let opt = try HTTP.GET("\(url)?access_token=\(token)", parameters: [], headers: ["Accept": "application/vnd.github.v3.raw"] ,requestSerializer: JSONParameterSerializer())
        opt.start { response in
            if response.error != nil {
                DispatchQueue.main.async(execute: {
                    print(response.error!.localizedDescription)
                    completionHandler(false, nil)
                })
                return //also notify app of failure as needed
            }
            DispatchQueue.main.async(execute: {
                completionHandler(true, String(data: response.data, encoding: .utf8))
            })
        }
    } catch let error {
        DispatchQueue.main.async(execute: {
            completionHandler(false, nil)
        })
        print(error.localizedDescription)
        assert(false, error.localizedDescription)
    }
}



func loadDirectory(url: String, token: String, completionHandler: @escaping ((Bool, [DirectoryTree?]) -> Void)) -> Void {
    
    do {
        let opt = try HTTP.GET("\(url)?access_token=\(token)")
        opt.start { response in
            if response.error != nil {
                DispatchQueue.main.async(execute: {
                    completionHandler(false, [nil])
                })
                return //also notify app of failure as needed
            }
            DispatchQueue.main.async(execute: {
                let childrens = setUpDirectories(JSONDecoder(response.data))
                loadDirectories(directories: childrens, token: token, completionHandler: { parentDirectories in
                    completionHandler(true, parentDirectories)
                })
            })
        }
    } catch let error {
        DispatchQueue.main.async(execute: {
            completionHandler(false, [nil])
        })
        assert(false, error.localizedDescription)
    }
}

func showNetworkIndicator(_ show: Bool) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = show
}

