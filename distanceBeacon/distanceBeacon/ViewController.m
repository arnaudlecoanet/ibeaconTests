//
//  ViewController.m
//  distanceBeacon
//
//  Created by cyril bele on 11/08/2014.
//  Copyright (c) 2014 muzen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    //on définit la couleur des cercles ici, noir
    red = 0.0/255.0;
    green = 0.0/255.0;
    blue = 0.0/255.0;
    opacity = 1.0;
    
    
    //On instancie notre dictionnaire pour se souvenir des beacons rencontrés
    self.beaconsData = [[NSMutableDictionary alloc] init];
    
    
    /* si vous souhaitez choisir l'ordre d'apparition des beacons, c'est ici
    NSDictionary *beacon1 = @{@"nb": @0};
    [self.beaconsData setObject:beacon1 forKey:@"46889_31899"];
    NSDictionary *beacon2 = @{@"nb": @1};
    [self.beaconsData setObject:beacon2 forKey:@"38656_21561"];
    NSDictionary *beacon3 = @{@"nb": @2};
    [self.beaconsData setObject:beacon3 forKey:@"26323_32358"];
    */
    
    
    //on instancie corelocation pour faire du range de beacons
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    if(![CLLocationManager isRangingAvailable]) {
        NSLog(@"Ranging not available for this device");
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:@"Error" message:@"Beacon ranging not available on device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
        
    }
    
    //on demarre la region beacon
    //Pensez à changer le UUID avec celui des beacons que vous avez
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"00112211-0328-1982-ABCD-987654321098"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"fr.muzen"];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    
    //et on surveille
    [self locationManager:self.locationManager didStartMonitoringForRegion:self.beaconRegion];
    
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
    
    //on vide l image précédente
    
    NSLog(@"width: %f",self.view.frame.size.width);
    NSLog(@"height: %f",self.view.frame.size.height);
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextClearRect(ctx, CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height));
    
    
    //on boucle sur les beacons
    
    for(CLBeacon *beacon in beacons) {
        NSLog(@"Major:%@ minor:%@ accuracy:%f rssi:%ld",beacon.major,beacon.minor,beacon.accuracy,(long)beacon.rssi);
        //on regarde si on connait le beacon, si non, on lui donne la place suivante sur l'écran
        NSString *key = [NSString stringWithFormat:@"%@_%@",beacon.major,beacon.minor];
        if(![self.beaconsData objectForKey:key]) {
            int nb = [self.beaconsData count];
            NSDictionary *beaconData = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:nb] forKey:@"nb"];
            [self.beaconsData setObject:beaconData forKey:key];
        }
        
        //on regarde la position sur l'écran du beacon fournit
        int num = [[[self.beaconsData objectForKey:key] objectForKey:@"nb"] intValue];
        
        
        //On dessine un cercle basé sur la distance fournit par l os
        //distance en mettre qu'on multiplie par 10 pour que ça se voit sur l'écran
        float radius = beacon.accuracy *50;
        
        // un peu de trigo pour calculer le rectangle qui contient le cercle qu'on souhaite afficher
        CGRect borderRect = CGRectMake(160.0f-radius, (100.0f + num*150)-radius, 2*radius,2*radius);
        
        //on colorise le fond et le bord
        CGContextSetRGBStrokeColor(ctx, 1.0, 1.0, 1.0, 1.0);
        CGContextSetRGBFillColor(ctx, red, green, blue, 0.0);
        CGContextSetLineWidth(ctx, 2.0);
        CGContextSetRGBStrokeColor(ctx, red, green, blue, 1.0);
        
        //on transforme le rectangle en ellipse et donc ici en cerlce vu que le rectangle est carré
        CGContextFillEllipseInRect (ctx, borderRect);
        CGContextStrokeEllipseInRect(ctx, borderRect);
        
        // je sais plus si ça cert mais on va le laisser
        CGContextFillPath(ctx);
        
        
    }
    
    //Ya plus qu'à mettre l'image dans le UIImage
    self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.tempDrawImage setAlpha:opacity];
    
    //et on arrête le contexte
    UIGraphicsEndImageContext();
    
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
