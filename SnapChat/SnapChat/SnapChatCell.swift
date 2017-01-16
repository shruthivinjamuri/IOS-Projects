//
//  SnapChatCell.swift
//  SnapChat
//
//  Created by Shruthi Vinjamuri on 11/12/16.
//  Copyright © 2016 Shruthi Vinjamuri. All rights reserved.
//

import UIKit

class SnapChatCell: UITableViewCell {
    
    @IBOutlet weak var CellStatusImage: UIImageView!
    @IBOutlet weak var CellStatus: UILabel!
    @IBOutlet weak var CellDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
