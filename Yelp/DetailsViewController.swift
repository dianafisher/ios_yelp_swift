//
//  DetailsViewController.swift
//  Yelp
//
//  Created by Diana Fisher on 9/24/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit
import MapKit

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!    
    @IBOutlet weak var reviewCountLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    var business: Business!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set navigationBar tint colors
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.8288504481, green: 0.1372715533, blue: 0.1384659708, alpha: 1)
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)        
        
        nameLabel.text = business.name
        phoneNumberLabel.text = business.phoneNumber
        categoriesLabel.text = business.categories
        addressLabel.text = business.address
        reviewCountLabel.text = "\(business.reviewCount!) Reviews"
        ratingImageView.setImageWith(business.ratingImageURL!)
        
        if let centerLocation = business.coordinate {
            let span = MKCoordinateSpanMake(0.1, 0.1)
                        
            let region = MKCoordinateRegionMake(centerLocation.coordinate, span)
            mapView.setRegion(region, animated: false)
            
            // Add a map annotation
            let annotation = MKPointAnnotation()
            annotation.coordinate = centerLocation.coordinate
            annotation.title = business.name
            mapView.addAnnotation(annotation)
        }
        
        if let thumbUrl = business.imageURL
        {
            let imageRequest = URLRequest(url: thumbUrl)
            detailImageView.setImageWith(
                imageRequest,
                placeholderImage: #imageLiteral(resourceName: "placeholder"),
                success: { (imageRequest, imageResponse, image) -> Void in
                    if imageResponse != nil {
                        self.detailImageView.alpha = 0.0
                        self.detailImageView.image = image
                        UIView.animate(withDuration: 0.3, animations: { () -> Void in
                            self.detailImageView.alpha = 1.0
                        })
                    } else {
                        self.detailImageView.image = image
                    }
                    
            }, failure: { (imageRequest, imageResponse, error) -> Void in
                print(error)
                self.detailImageView.image = #imageLiteral(resourceName: "placeholder")
            })
        } else {
            detailImageView.image = #imageLiteral(resourceName: "placeholder")
        }

        detailImageView.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
