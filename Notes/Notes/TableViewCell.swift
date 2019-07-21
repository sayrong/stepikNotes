//
//  TableViewCell.swift
//  Notes
//
//  Created by Dima on 20/07/2019.
//  Copyright © 2019 Babette Alvyn sharp. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var customTitle: UILabel!
    @IBOutlet weak var customDescription: UILabel!
    
    var bgColor: UIColor?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        colorView.layer.borderColor = UIColor.black.cgColor
        colorView.layer.borderWidth = 1
        // Initialization code
    }
    
    
    //OMG fcking color disappear
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        bgColor = colorView.backgroundColor
        super.setHighlighted(highlighted, animated: animated)
        colorView.backgroundColor = bgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        bgColor = colorView.backgroundColor
        super.setSelected(selected, animated: animated)
        colorView.backgroundColor = bgColor
    }
    
}
