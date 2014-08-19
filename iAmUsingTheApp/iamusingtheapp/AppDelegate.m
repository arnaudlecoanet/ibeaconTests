//
//  AppDelegate.m
//  iamusingtheapp
//
//  Created by cyril bele on 19/08/2014.
//  Copyright (c) 2014 muzen. All rights reserved.
//

#import "AppDelegate.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //on défini un UUID pour pas être parasité par d'autres applications
    _appUUID = [[NSUUID alloc] initWithUUIDString:@"00112211-0328-1982-ABCD-987654321098"];
    
    
    // le gestionnaire du bluetooth
    //on doit attendre qu'il soit actif pour pouvoir commencer à émettre
    _peripheralManager = [[CBPeripheralManager alloc]
                                              initWithDelegate:self
                                              queue:dispatch_get_main_queue()];
    
    //On démarre la deuxième partie qui consiste à être réveillé quand un beacon est détecté;
    if([CLLocationManager locationServicesEnabled]) {
        [self initiateBeaconTracking];
    } else NSLog(@":-( le service de localisation n'est pas actif");
    
    
    return YES;
}

#pragma mark gestion du beacon en réception
-(void) initiateBeaconTracking{
    NSLog(@"On met en place la gestion du location manager pour être prévenu quand un beacon est détecté");
    self.locationManager = [[CLLocationManager alloc] init];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:_appUUID identifier:@"fr.muzen"];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"error location manager: %@",error);
}


- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    
    NSLog(@"Une autre personne en train d'utiliser l'application vient d'être détectée");
    
    // On notifie localement l'utilisateur si il n'utilise pas déjà l'application
    if([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = @"une autre personne est en train d'utiliser l'application dans les parages";
        notification.soundName = @"Default";
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    } else {
        NSLog(@"L'application est active donc pas besoin de notifier");
    }
    
    
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    
    NSLog(@"did exit  region triggered");
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
}



#pragma mark gestion du bluetooth

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        NSLog(@"statut du périphérique a changé mais pas On");
        return;
    }
    
    NSLog(@"On démarre l'utilisation du téléphone comme un iBeacon");
    CLBeaconRegion *advertisingRegion = [[CLBeaconRegion alloc]
                                         initWithProximityUUID:_appUUID
                                         major:123
                                         minor:456
                                         identifier:@"muzen.fr"];
    
    _peripheralData = [advertisingRegion peripheralDataWithMeasuredPower:nil];
    [_peripheralManager startAdvertising:_peripheralData];
    
}

							
- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"On quitte le mode actif donc on arrête l'émission");
    [_peripheralManager stopAdvertising];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"On repasse devant, on recommence les émissions");
    if(_peripheralManager.state == CBPeripheralManagerStatePoweredOn) {
        NSLog(@"Le périphérique est actif, on peut redémarrer les émissions");
        [_peripheralManager startAdvertising:_peripheralData];
    }
}

@end
