//
//  AppDelegate.h
//  realtimeIBeaconData
//
//  Created by cyril bele on 26/08/2014.
//  Copyright (c) 2014 muzen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Firebase/Firebase.h>
#import <CoreLocation/CoreLocation.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;


//Les données apple pour le beacon et l outil de localisation
@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;
//Le lien vers firebase
@property (strong, nonatomic) Firebase* fireBaseRootRef;
//Et un UID pour l utilisateur afin de pouvoir les identifier de manière anonyme
@property (strong, nonatomic) NSString* userId;

@end
