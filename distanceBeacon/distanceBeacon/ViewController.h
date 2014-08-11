//
//  ViewController.h
//  distanceBeacon
//
//  Created by cyril bele on 11/08/2014.
//  Copyright (c) 2014 muzen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController<CLLocationManagerDelegate>
{
    
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat opacity;
    
}


@property (weak, nonatomic) IBOutlet UIImageView *tempDrawImage;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) NSMutableDictionary *beaconsData;


@end
