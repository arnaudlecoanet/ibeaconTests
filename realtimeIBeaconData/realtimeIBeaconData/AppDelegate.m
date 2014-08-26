//
//  AppDelegate.m
//  realtimeIBeaconData
//
//  Created by cyril bele on 26/08/2014.
//  Copyright (c) 2014 muzen. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    
    //on demarre la region beacon
    //et on surveille
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"00112233-0328-1982-ABCD-987654321098"];
    _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"fr.muzen.blog"];
    [_locationManager startMonitoringForRegion:_beaconRegion];

    
    //On configure le lien vers firebase
    _fireBaseRootRef = [[Firebase alloc] initWithUrl:@"https://demobeacon.firebaseio.com/beaconsReading/"];
    //et on se trouve un identifiant qui permet de savoir qui est l'utilisateur
    _userId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    
    return YES;
}

//on ajoute dans le location manager comme quoi on est intéressé par les beacons

 - (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

//dès qu'on est prévenu que le beacon est dans le coin, on commence le ranging
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"At least one beacon entered region");
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}


-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {

    // On écrit les données dans la base
    
    //on commence par noter le timestamp de la mesure
    NSTimeInterval  timestamp = [[NSDate date] timeIntervalSince1970];
    int time = (int) timestamp;
    NSString *timeKey = [NSString stringWithFormat:@"%d",time];
    
    //pour chaque beacon, on écrit dans la base
    for(CLBeacon *beacon in beacons) {
    
        NSDictionary *beaconData = @{
                                     @"RSSI":[NSString stringWithFormat:@"%ld", (long)beacon.rssi],
                                     @"accuracy":[NSString stringWithFormat:@"%f", beacon.accuracy],
                                     @"proximity":[NSString stringWithFormat:@"%d", beacon.proximity],
                                     };
        //on se met au bon endroit pour écrire
        NSString *beaconPath = [NSString stringWithFormat:@"%@/%@/%@/%@/",beacon.major,_userId,beacon.minor,timeKey];
        Firebase *measureRef = [_fireBaseRootRef childByAppendingPath: beaconPath];

        
        //on envois les données des iBeacons vers la base
        [measureRef setValue:beaconData];
    }
}




@end
