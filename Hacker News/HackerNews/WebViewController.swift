//
//  WebViewController.swift
//  HackerNews
//
//  Created by Shruthi Vinjamuri on 11/20/16.
//  Copyright © 2016 Shruthi Vinjamuri. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet var webView: UIWebView!
    var urlString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: self.urlString!)
        let request = URLRequest(url: url!)
        if let web = self.webView {
            web.loadRequest(request)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webViewDidStartLoad(_ webView: UIWebView)
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    func webViewDidFinishLoad(_ webView: UIWebView)
    {
       UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
