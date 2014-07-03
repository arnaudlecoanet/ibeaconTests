//
//  ViewController.h
//  detectBeacon
//
//  Created by admin on 03/07/2014.
//  Copyright (c) 2014 muzen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *beaconTrouveLabel;

//les données statitiques du beacon
@property (weak, nonatomic) IBOutlet UILabel *UUIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *MajorLabel;
@property (weak, nonatomic) IBOutlet UILabel *MinorLabel;

//les données dynamiques du beacon
@property (weak, nonatomic) IBOutlet UILabel *proximityLabel;
@property (weak, nonatomic) IBOutlet UILabel *accuracyLabel;
@property (weak, nonatomic) IBOutlet UILabel *RSSILabel;

//Les données apple pour le beacon et l outil de localisation
@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end
