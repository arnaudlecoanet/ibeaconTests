//
//  AppDelegate.h
//  iamusingtheapp
//
//  Created by cyril bele on 19/08/2014.
//  Copyright (c) 2014 muzen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,CBPeripheralManagerDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;



@property (strong, nonatomic) NSUUID *appUUID;

//Gestion du téléphone comme beacon
@property (strong,nonatomic) CBPeripheralManager *peripheralManager;
@property (strong,nonatomic) NSDictionary *peripheralData;

//reception du beacon
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion;

@end
