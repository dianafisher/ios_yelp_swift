//
//  BusinessCell.swift
//  Yelp
//
//  Created by Diana Fisher on 9/20/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessCell: UITableViewCell {

    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var reviewCountLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    
    var business: Business! {
        didSet {
            nameLabel.text = business.name
            categoriesLabel.text = business.categories
            addressLabel.text = business.address
            reviewCountLabel.text = "\(business.reviewCount!) Reviews"
            ratingImageView.setImageWith(business.ratingImageURL!)
            distanceLabel.text = business.distance
            
            if let thumbUrl = business.imageURL
            {
                let imageRequest = URLRequest(url: thumbUrl)
                thumbImageView.setImageWith(
                    imageRequest,
                    placeholderImage: UIImage(named: "placeholder"),
                    success: { (imageRequest, imageResponse, image) -> Void in
                        if imageResponse != nil {
                            self.thumbImageView.alpha = 0.0
                            self.thumbImageView.image = image
                            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                                self.thumbImageView.alpha = 1.0
                            })
                        } else {
                            self.thumbImageView.image = image
                        }
                        
                }, failure: { (imageRequest, imageResponse, error) -> Void in
                    print(error)
                    self.thumbImageView.image = UIImage(named: "placeholder")
                })
            } else {
                thumbImageView.image = UIImage(named: "placeholder")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // round the corners of the UIImageView
        thumbImageView.layer.cornerRadius = 3
        thumbImageView.clipsToBounds = true
        
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
