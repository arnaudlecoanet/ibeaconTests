//
//  ViewController.m
//  detectBeacon
//
//  Created by admin on 03/07/2014.
//  Copyright (c) 2014 muzen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController 

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //On instancie corelocation
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    //on demarre la region beacon
    [self initRegion];
    //et on surveille
    [self locationManager:self.locationManager didStartMonitoringForRegion:self.beaconRegion];
    
}

//on ajoute dans le location manager comme quoi on est intéressé par les beacons
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

//on demarre la region, il faut obligatoirement connaitre le UUID pour cela
//dans un use case d entreprise, il faudra donc faire attention à mettr ele même UUID sur tous les beacons
//et utiliser le major et le minor pour séparer les différents use cases
- (void)initRegion {
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"fr.muzen.blog"];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
}


//dès qu'on est prévenu que le beacon est dans le coin, on commence le ranging
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    NSLog(@"At least one beacon entered region");
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

//quand le beacon disparait, on arrête le ranging
-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"Left Region");
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    self.beaconTrouveLabel.text = @"Non";
    self.UUIDLabel.text = @"";
    self.MajorLabel.text = @"";
    self.MinorLabel.text = @"";
    self.accuracyLabel.text = @"";
    self.proximityLabel.text = @"";
    self.RSSILabel.text = @"";
}






-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    CLBeacon *beacon = [[CLBeacon alloc] init];
    beacon = [beacons lastObject];
    
    NSLog(@"nb beacons: %d",[beacons count]);
    
    if([beacons count] == 0) {
        self.beaconTrouveLabel.text = @"Non";
        self.UUIDLabel.text = @"";
        self.MajorLabel.text = @"";
        self.MinorLabel.text = @"";
        self.accuracyLabel.text = @"";
        self.proximityLabel.text = @"";
        self.RSSILabel.text = @"";
        
        return;
        
    }
    
    self.beaconTrouveLabel.text = @"Oui";
    self.UUIDLabel.text = beacon.proximityUUID.UUIDString;
    self.MajorLabel.text = [NSString stringWithFormat:@"%@", beacon.major];
    self.MinorLabel.text = [NSString stringWithFormat:@"%@", beacon.minor];
    self.accuracyLabel.text = [NSString stringWithFormat:@"%f", beacon.accuracy];
    if (beacon.proximity == CLProximityUnknown) {
        self.proximityLabel.text = @"Inconnu";
    } else if (beacon.proximity == CLProximityImmediate) {
        self.proximityLabel.text = @"Immédiat";
    } else if (beacon.proximity == CLProximityNear) {
        self.proximityLabel.text = @"A côté";
    } else if (beacon.proximity == CLProximityFar) {
        self.proximityLabel.text = @"Loin";
    }
    self.RSSILabel.text = [NSString stringWithFormat:@"%i", beacon.rssi];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
