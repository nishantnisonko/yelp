//
//  Businessswift
//  Yelp
//
//  Created by Nishant nishanko on 4/7/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessCell: UITableViewCell {

    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var reviewCountLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var business: Business! {
        didSet {
            nameLabel.text = business.name
            addressLabel.text = business.address
            categoriesLabel.text = business.categories
            reviewCountLabel.text = "\(business.reviewCount!) Reviews"
            distanceLabel.text = business.distance
            if business.imageURL != nil {
                thumbImageView.setImageWith(business.imageURL!)
            }
            if business.ratingImageURL != nil {
                ratingImageView.setImageWith(business.ratingImageURL!)
            }
            

        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        thumbImageView.layer.cornerRadius = 3
        nameLabel.preferredMaxLayoutWidth = nameLabel.frame.size.width
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.preferredMaxLayoutWidth = nameLabel.frame.size.width
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
