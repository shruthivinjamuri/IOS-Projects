//
//  ViewController.swift
//  Assign4Practice
//
//  Created by Shruthi Vinjamuri on 10/15/16.
//  Copyright © 2016 Shruthi Vinjamuri. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var logoBarView: UIView!
    
    @IBOutlet weak var btnNo: UIButton!
    
    @IBOutlet weak var btnLove: UIButton!
    
    fileprivate let names = ["Sophia","Emma","Olivia","Maya Ava","Isabella","Violet","Samantha","Lily","Madison","Aria","Scarlett","Brooklyn","Elizabeth","Victoria","Claire","Ellen"]
    fileprivate var idxToAdd: Int = 0
    fileprivate let Action_Margin = CGFloat(120)
    fileprivate let Rotation_Angle = CGFloat(M_PI)/8.0
    fileprivate let Max_Animation_Distance = CGFloat(320.0)
    fileprivate var lastFive = [Int](repeatElement(-1, count: 5))
    fileprivate var overlay = UIImageView()
    fileprivate var origin = CGPoint()
    fileprivate let yarpImage = UIImage(named: "yarp.png")
    fileprivate let narpImage = UIImage(named: "narp.png")
    fileprivate var cardView: UIView? = nil
    fileprivate var imageView: UIImageView? = nil
    fileprivate var lblNameAge: UILabel? = nil
    fileprivate var restored = false
    fileprivate var narpPosition: CGRect? = nil
    fileprivate var yarpPosition: CGRect? = nil
    fileprivate var topCard: UIView! =  nil
    fileprivate var middleCard: UIView! = nil
    fileprivate var bottomCard: UIView! = nil {
        didSet {
            if self.topCard != nil {
                self.view.addSubview(self.bottomCard)
                self.view.addSubview(self.middleCard)
                self.view.addSubview(self.topCard)
                let recog = UIPanGestureRecognizer(target: self, action: #selector(self.onPanGesture(_:)))
                self.topCard?.addGestureRecognizer(recog)
                self.topCard?.addSubview(self.overlay)
                self.overlay.isHidden = true
                restored = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // black-border
        let blackBorder = UIView()
        let posBlackBorder = CGRect(x: 0, y: 39, width: UIScreen.main.bounds.width, height: 1)
        blackBorder.frame = posBlackBorder
        blackBorder.backgroundColor = UIColor.black
        logoBarView.addSubview(blackBorder)
        
        self.overlay.contentMode = UIViewContentMode.scaleAspectFit
        
        loadStackOfCards()
        
        if self.cardView != nil {
            self.narpPosition = CGRect(x: 0.5 * self.cardView!.bounds.width - 20,
                                       y: 20,
                                       width: 0.5 * self.cardView!.bounds.width,
                                       height: 0.4 * self.cardView!.bounds.width)
            self.yarpPosition = CGRect(x: 20,
                                       y: 20,
                                       width: 0.5 * self.cardView!.bounds.width,
                                       height: 0.4 * self.cardView!.bounds.width)
        }
        
    }

    @IBAction func btnNo(_ sender: UIButton) {
        // this will make sure that continous clicks 
        // won't create random animations unitl we restore
        // the stacks
        if restored {
            restored = false
            self.showOverlay(view: self.topCard!, left: true)
            self.animateAway(view: self.topCard!, left: true)
        }
        UIView.animate(withDuration: 0.1,
                        animations: {self.btnNo.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)},
                        completion: { finish in
                                UIView.animate(withDuration:0.1, animations: {self.btnNo.transform = CGAffineTransform.identity})
        })
    }
    
    @IBAction func btnLove(_ sender: UIButton) {
        // this will make sure that continous clicks
        // won't create random animations unitl we restore
        // the stacks
        if restored {
            restored = false
            self.showOverlay(view: self.topCard!, left: false)
            self.animateAway(view: self.topCard!, left: false)
        }
        UIView.animate(withDuration: 0.1,
                       animations: {self.btnLove.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)},
                       completion: { finish in
                        UIView.animate(withDuration:0.1, animations: {self.btnLove.transform = CGAffineTransform.identity})
        })
    }
    
    fileprivate func loadStackOfCards() {
        // Initialize a card
        initCard()
        
        // Assign properties to the new card
        setUpCards()
        
        // put the cardView at the bottom since it acts as the third card
        // and the stack should start with it, so no animation.
        self.cardView?.frame = self.cardView!.frame.offsetBy(dx: 0, dy: +80)
        self.cardView?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.5, animations: { () in
            self.middleCard?.frame = self.middleCard!.frame.offsetBy(dx: 0, dy: -40)
            self.bottomCard?.frame = self.bottomCard!.frame.offsetBy(dx: 0, dy: -40)
            self.middleCard?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.bottomCard?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }, completion: { success in
                self.topCard = self.middleCard
                self.middleCard = self.bottomCard
                self.bottomCard = self.cardView!
                
                // Recursively setup the stack of cards
                if self.topCard == nil {
                    self.loadStackOfCards()
                }
        })
    }
    
    fileprivate func initCard() {
        // Initializes a card view and it's layout
        
        // holder for card
        let bounds = UIScreen.main.bounds
        self.cardView = UIView()
        self.cardView?.frame = CGRect(x: 50, y: 60, width: 0.75*bounds.width, height: bounds.height - 250)
        self.cardView?.backgroundColor = UIColor.white
        self.cardView?.layer.cornerRadius = 10
        self.cardView?.layer.masksToBounds = true
        self.cardView?.layer.borderWidth = 1.0
        self.cardView?.layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1).cgColor
        self.cardView?.center = self.view.center
        self.cardView?.center.y = self.view.center.y - 40
        
        // holder for a image in the card
        self.imageView = UIImageView()
        self.imageView?.contentMode = UIViewContentMode.scaleAspectFill
        self.imageView?.frame = CGRect(x: 0,
                                       y: 0,
                                       width: self.cardView!.bounds.width,
                                       height: self.cardView!.bounds.height - 50)
        self.cardView?.addSubview(self.imageView!)
        
        // bottom white background view
        let whiteView = UIView()
        whiteView.frame = CGRect(x: 0,
                                 y: self.imageView!.bounds.height,
                                 width: self.cardView!.bounds.width,
                                 height: self.cardView!.bounds.height - self.imageView!.bounds.height)
        whiteView.backgroundColor = UIColor.white
        self.cardView?.addSubview(whiteView)
        
        // label which would show the name and age
        self.lblNameAge = UILabel()
        self.lblNameAge?.frame = CGRect(x: 10,
                                        y: 0,
                                        width: self.cardView!.bounds.width - 10,
                                        height: self.cardView!.bounds.height - self.imageView!.bounds.height)
        whiteView.addSubview(self.lblNameAge!)
    }
    
    fileprivate func setUpCards() {
        let profile = getProfiles()
        self.imageView?.image = UIImage(named: profile.picture)
        let age = String(arc4random_uniform(UInt32(8)) + 24)
        let attrAge = NSMutableAttributedString(string: age)
        attrAge.addAttribute(NSForegroundColorAttributeName, value: UIColor.lightGray, range: attrAge.mutableString.range(of: age))
        let attrName = NSMutableAttributedString(string: profile.name)
        attrName.append(attrAge)
        self.lblNameAge?.attributedText = attrName
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onPanGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        
        switch sender.state {
        case .began:
            self.origin = sender.view!.center
        case .changed:
            let rotationAngle = Rotation_Angle * max(min(translation.x/Max_Animation_Distance, 1), -1)
            let alpha = max(1 - (abs(translation.x)/self.Max_Animation_Distance), 0.7)
            let transform = CGAffineTransform(rotationAngle: rotationAngle)
            
            // Animate the top card based on the touch gesture movement
            UIView.animate(withDuration: 0.5, animations: { () in
                sender.view!.transform = transform
                sender.view!.center = CGPoint(x: self.origin.x+translation.x, y: self.origin.y + translation.y)
                sender.view!.alpha = CGFloat(alpha)
            })
            
            // Check, if we have to show overlay image
            if abs(translation.x) > Action_Margin/3 {
                showOverlay(view: sender.view!, left: translation.x < 0)
            }
            
        case .ended:
            if abs(translation.x) < Action_Margin {
                // reset to original position
                UIView.animate(withDuration: 0.5, animations: {() in
                    self.overlay.isHidden = true
                    sender.view!.transform = CGAffineTransform(rotationAngle: 0)
                    sender.view!.center = self.view.center
                    sender.view!.center.y = sender.view!.center.y - 40
                    sender.view!.alpha = CGFloat(1)
                    })
            }
            else { // swipe away case
                self.animateAway(view: sender.view!, left: translation.x < 0)
            }
        default:
            break
        }
    }
    
    fileprivate func showOverlay(view: UIView, left: Bool) {
        self.overlay.isHidden = false
        switch left {
        case true:
            self.overlay.image = self.narpImage
            self.overlay.frame = self.narpPosition!
        case false:
            self.overlay.image = self.yarpImage
            self.overlay.frame = self.yarpPosition!
        }
    }
    
    fileprivate func animateAway(view: UIView, left: Bool){
        let width = UIScreen.main.bounds.width
        UIView.animate(withDuration: 0.5, animations: { () in
            view.transform = CGAffineTransform(rotationAngle: (left ? -1.0 * self.Rotation_Angle : self.Rotation_Angle))
            view.center.x = left ? ((width/2) - 3 * (width/2)) : ((width/2) + 3 * (width/2))
            }, completion: { success in
                view.subviews.forEach({ $0.removeFromSuperview() })
                view.removeFromSuperview()
            })
        loadStackOfCards()
    }
    
    fileprivate func getProfiles() -> (name: String, picture: String) {
        var idxCur = Int(arc4random_uniform(UInt32(16)))
        while !addElseFail(value: idxCur) {
            idxCur = Int(arc4random_uniform(UInt32(16)))
        }
        var name = names[idxCur]
        name.append(", ")
        var picture = "profile"
        picture.append(String(idxCur+1))
        picture.append(".png")
        return (name, picture)
    }
    
    fileprivate func addElseFail(value: Int) -> Bool {
        if value == -1 || lastFive.contains(value) {
            return false
        }
        
        lastFive[idxToAdd] = value
        idxToAdd = (idxToAdd + 1) % lastFive.count
        return true
    }

}

