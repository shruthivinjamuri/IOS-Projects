//
//  LoginViewController.swift
//  GitHub
//
//  Created by Shruthi Vinjamuri on 11/30/16.
//  Copyright © 2016 Shruthi Vinjamuri. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnSignInClick: UIButton!
    
    @IBOutlet weak var loginView: UIView!
    var auth: Authorization?
    var user: UserProfile?
    var repoManager: RepoManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtPassword.isSecureTextEntry = true
        
        btnSignInClick.layer.cornerRadius = 5
        btnSignInClick.layer.borderWidth = 1
        btnSignInClick.layer.masksToBounds = true
        
        //border colors
        txtPassword.layer.borderWidth = 1
        txtUserName.layer.borderWidth = 1
        txtUserName.layer.cornerRadius = 5
        txtPassword.layer.cornerRadius = 5
        txtPassword.layer.masksToBounds = true
        txtUserName.layer.masksToBounds = true
        txtUserName.layer.borderColor = UIColor(red: 102/255, green: 204/255, blue: 1, alpha: 1).cgColor
        txtPassword.layer.borderColor = UIColor(red: 102/255, green: 204/255, blue: 1, alpha: 1).cgColor
        txtUserName.tintColor = UIColor(red: 102/255, green: 204/255, blue: 1, alpha: 1)
        txtPassword.tintColor = UIColor(red: 102/255, green: 204/255, blue: 1, alpha: 1)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onReturnKeyPress(_ sender: UITextField) {
        login(sender: sender)
    }

    // MARK: - Navigation

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return true
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMainScreen", let user = self.user {
            
            let controller = segue.destination as! SWRevealViewController
            controller.loadView()
            
            // front view controller
            let homeController = (controller.frontViewController as! UINavigationController).topViewController as! HomeViewController
            homeController.profileData = user
            homeController.repoManager = self.repoManager
            
            // rear view controller data
            let rearController = controller.rearViewController as! MenuController
            rearController.menuData = MenuProfile(profilePic: (self.user?.profilePicImg)!, name: (self.user?.name)!)
            rearController.profileData = self.user
            rearController.repoManager = self.repoManager
            
        }
    }
    
    @IBAction func onLoginClick(_ sender: UIButton) {
        login(sender: sender)
    }
    
    @IBAction func logoutOnExit(_ segue: UIStoryboardSegue) {
        if let passwordField = self.txtPassword {
            passwordField.text = ""
        }
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func login(sender: Any?) {
        if let userNameField = txtUserName, let passwordField = txtPassword {
            if userNameField.text == nil || userNameField.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).characters.count == 0 {
                let alert = UIAlertView(title: "Invalid", message: "Please enter valid username.", delegate: self, cancelButtonTitle: "OK")
                alert.show()
                return
            }
            
            if passwordField.text == nil || passwordField.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).characters.count == 0 {
                let alert = UIAlertView(title: "Invalid", message: "Please enter valid password.", delegate: self, cancelButtonTitle: "OK")
                alert.show()
                return
            }
            
            let spinner: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            spinner.frame = CGRect(x: self.view.center.x - 20, y: self.view.center.y + (self.loginView.bounds.height/2) + 20, width: 50, height: 50)
            self.view.addSubview(spinner)
            spinner.startAnimating()
            
            if let userName = userNameField.text {
                if let password = passwordField.text {
                    let login = Login(username: userName, password: password)
                    login.tryLogin(completionHandler: { (status: Bool) in
                        if status { // login success.
                            self.auth = login.auth
                            print ("token: \(self.auth!.token!)")
                            let profile = Profile(clientId: (self.auth?.clientId!)!, clientSecret: (self.auth?.clientSecret!)!, token: (self.auth?.token!)!)
                            profile.getProfile(completionHandler: {(status: Bool) in
                                if status {
                                    self.user = profile.userData
                                    //print ("token: \(self.auth?.token)")
                                    let repo = Repos(token: (self.auth?.token)!, loginName: (self.user?.loginName)!)
                                    repo.getRepos(completionHandler: { (status: Bool) in
                                        if status {
                                            self.repoManager = repo.repoManager
                                            self.repoManager?.handleContributions(completionHandler: { (status: Bool, repoId: Int, segue: Bool) in
                                                if status {
                                                    self.repoManager?.populateContributions(id: repoId)
                                                }
                                                if segue && status {
                                                    spinner.stopAnimating()
                                                    self.performSegue(withIdentifier: "showMainScreen", sender: sender)
                                                }
                                            })
                                        }
                                        else {
                                            //print("error in getting repos")
                                            spinner.stopAnimating()
                                            self.performSegue(withIdentifier: "showMainScreen", sender: sender)
                                        }
                                    })                                }
                                else {
                                    //print ("error in getting user")
                                    spinner.stopAnimating()
                                    self.performSegue(withIdentifier: "showMainScreen", sender: sender)
                                }
                            })

                        } else { // login fail case
                            let alert = UIAlertView(title: "Login Error", message: "Invalid username or password.", delegate: self, cancelButtonTitle: "Retry?")
                            alert.show()
                        }
                    }) // completion handler
                } //
            }
        }
    }

}
