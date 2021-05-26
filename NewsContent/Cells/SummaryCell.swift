//
//  SummaryCell.swift
//  NewsContent
//
//  Created by mozeX on 25.05.2021.
//

import UIKit

class SummaryCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageMode: UIImageView!
    
    var selectedMode: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        if selectedMode == 0 {
            imageMode.image = UIImage(systemName: "chevron.right")
            imageMode.tintColor = UIColor.systemYellow
        } else {
            imageMode.image = UIImage(systemName: "minus.circle.fill")
            imageMode.tintColor = UIColor.systemRed
        }
    }

}
