//
//  ViewController.h
//  iBeaconGeolocation
//
//  Created by cyril bele on 12/08/2014.
//  Copyright (c) 2014 muzen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController<CLLocationManagerDelegate>

//sur l'écran
@property (weak, nonatomic) IBOutlet UIImageView *drawingView;
@property (weak, nonatomic) IBOutlet UILabel *actionLabel;

//pour stocker les données des beacons
@property (strong,nonatomic) NSMutableArray *beaconsData;
@property (weak, nonatomic) NSNumber *step;

//la localisation
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion;


@end
