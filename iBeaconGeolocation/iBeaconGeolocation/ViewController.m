//
//  ViewController.m
//  iBeaconGeolocation
//
//  Created by cyril bele on 12/08/2014.
//  Copyright (c) 2014 muzen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    
    self.beaconsData = [[NSMutableArray alloc] init];
    
    //Si vous voulez jouez avec d'autres formes que le triangle rectangle, c'est ici qu'il faut changer
    //j ai pris un triangle rectangle de 3m de côté
    NSDictionary *beacon1 = @{
                                @"key": @"",
                                @"point":[NSValue valueWithCGPoint:CGPointMake(10.f,500.f)],
                                @"color":[UIColor colorWithRed:0.5 green:0 blue:0.3 alpha:1.0],
                                @"num":@0
                            };
    [self.beaconsData setObject:[beacon1 mutableCopy] atIndexedSubscript:[self.beaconsData count]];
    
    
    NSDictionary *beacon2 = @{
                                @"key": @"",
                                @"point":[NSValue valueWithCGPoint:CGPointMake(85.f,350.f)],
                                @"color":[UIColor colorWithRed:0.2 green:0.7 blue:0.6 alpha:1.0],
                                @"num":@1
                            };
    [self.beaconsData setObject:[beacon2 mutableCopy] atIndexedSubscript:[self.beaconsData count]];
    
    
    NSDictionary *beacon3 = @{
                                @"key": @"",
                                @"point":[NSValue valueWithCGPoint:CGPointMake(160.f,500.f)],
                                @"color":[UIColor colorWithRed:0.8 green:0.4 blue:0.5 alpha:1.0],
                                @"num":@2
                            };
    [self.beaconsData setObject:[beacon3 mutableCopy] atIndexedSubscript:[self.beaconsData count]];
    
    
    
    self.step = [NSNumber numberWithInt:1];
    [self loadNextStep];
    
    
    
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
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"00112233-0328-1982-ABCD-987654321098"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"fr.muzen"];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    
    //et on surveille
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    
    
    
}



-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    NSLog(@"ranging");
    int step = [self.step intValue];
    if(step <=3) {
        
        //On boucle sur les différents beacons
        for(CLBeacon *beacon in beacons) {
            NSString *beaconKey = [NSString stringWithFormat:@"%@_%@",beacon.major,beacon.minor];
            //on a trouvé un beacon en proximité immédiate
            if (beacon.proximity == CLProximityImmediate) {
                
                NSLog(@"beacon found with immediate proximity");
                //on regarde si il n'est pas déjà enregistré (pour éviter les rebonds style le même beacon est identifié 2 fois de suite- à 2 sommets différents)
                bool beaconFound = NO;
                for(int i=0;i<=2;i++) {
                    NSMutableDictionary *beaconSaved = [self.beaconsData objectAtIndex:i];
                   
                    NSString *beaconSavedKey = [beaconSaved valueForKey:@"key"];
                    NSLog(@"%i: savedKey:%@ beaconKey:%@",i,beaconSavedKey,beaconKey);
                    NSLog(@"is matching: %i",beaconSavedKey == beaconKey);
                    
                    if([beaconKey  isEqualToString:beaconSavedKey]) {
                        NSLog(@"already saved");
                        beaconFound = YES;
                    }
                }
                
                //Si le beacon n'est pas trouvé, on enregistre son major et son minor dans l'array des beacons sous la forme key = major_minor
                NSLog(@"beacon found %d",beaconFound);
                if(!beaconFound) {
                    
                    NSLog(@"saving beacon");
                    NSMutableDictionary *beaconSaved = [self.beaconsData objectAtIndex:step-1];
                    [beaconSaved setObject:beaconKey forKey:@"key"];
                    [self.beaconsData setObject:[beaconSaved mutableCopy] atIndexedSubscript:step-1];
                    NSLog(@"loading next step");
                    self.step = [NSNumber numberWithInt:step+1];
                    [self loadNextStep];
                    
                }
            }
        }
        
    } //end step <=3
    
    if(step == 4){
        //on vide le canvas
        UIGraphicsBeginImageContext(self.view.frame.size);
        [self.drawingView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextClearRect(ctx, CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height));
        
        //On dessine les 3 beacons
        for(int i=0;i<=2;i++) {
            NSMutableDictionary *beacon = [self.beaconsData objectAtIndex:i];
            
            CGPoint myPoint = [[beacon objectForKey:@"point"] CGPointValue];
            
            int width = 10;

            UIColor *beaconColor = [beacon objectForKey:@"color"];
            CGContextSetFillColorWithColor(ctx, beaconColor.CGColor);
            
            CGContextFillRect(ctx, CGRectMake(myPoint.x - 5,myPoint.y - 5,width,width));
        }
        
        
        //on multiplie la mesure en mètre par 50 qui est l'unité utilisée pour le positionnement des beacons (50px = 1 mètre)
        float ratio = 50.0f;
        
        NSMutableDictionary *radiusList = [[NSMutableDictionary alloc] init];
        
        // on dessine les distances mesurées sous forme de cercles
        for(CLBeacon *beacon in beacons) {
            NSString *beaconKey = [NSString stringWithFormat:@"%@_%@",beacon.major,beacon.minor];
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@", beaconKey];
            NSArray *elem = [self.beaconsData filteredArrayUsingPredicate:predicate];
            if([elem count] !=1) {
                NSLog(@"beacon not found");
                continue;
            }
            NSDictionary *beaconData = [elem objectAtIndex:0];
            
            float radius =beacon.accuracy * ratio;
            [radiusList setObject:[NSNumber numberWithDouble:radius]  forKey:beaconKey];
            
            CGPoint center = [[beaconData objectForKey:@"point"] CGPointValue];
            UIColor * color =[beaconData objectForKey:@"color"];
            
            NSLog(@"radius:%f",radius);
            
            //ICI le dessin en lui même
            CGContextBeginPath(ctx);
            CGContextSetLineWidth(ctx, 1);
            CGContextSetStrokeColorWithColor(ctx, color.CGColor);
            CGContextAddArc(ctx, center.x, center.y, radius, 0, 2*M_PI, 0);
            CGContextStrokePath(ctx);
            
        } //end foreach beacon ranged
        
        
        //on stocke le radius dans les données des beacons
        for(int i=0;i<=2;i++) {
            NSMutableDictionary *beacon = [self.beaconsData objectAtIndex:i];
            [beacon setObject:[radiusList objectForKey:[beacon objectForKey:@"key"]] forKey:@"radius"];
            [self.beaconsData setObject:beacon atIndexedSubscript:i];
        }
        //on envois tout cela à l'algorithme de trilaration qui nous retourne un point qu'il suffit de déssiner
        CGPoint point = [self trilaterate];
        CGContextSetRGBFillColor(ctx, 1.0, 0.5, 0.2, 1.0);
        CGContextFillRect(ctx, CGRectMake(point.x - 10,point.y - 10,20,20));
        
        //Ya plus qu'à mettre l'image dans le UIImage
        self.drawingView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    } //end step = 4
}


- (void) loadNextStep{
    int step = [self.step intValue];
    NSLog(@"loading step: %i",step);
    
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [self.drawingView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextClearRect(ctx, CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height));
    
    
    if(step <= 3) {
        if(step == 1) self.actionLabel.text = @"étape 1: collez le téléphone au beacon à la base du triangle rectangle";
        if(step == 2) self.actionLabel.text = @"étape 2: collez le téléphone au beacon au premier sommet";
        if(step == 3) self.actionLabel.text = @"étape 3: collez le téléphone au beacon au deuxième sommet";
        
        for(int i=0;i<=2;i++) {
            NSMutableDictionary *beacon = [self.beaconsData objectAtIndex:i];
            
            CGPoint myPoint = [[beacon objectForKey:@"point"] CGPointValue];
            
            int width = 10;
            if(i == step - 1) {
                CGContextSetRGBFillColor(ctx, 1.0, 0.0, 0.0, 1.0);
                width = 30;
            } else {
                UIColor *beaconColor = [beacon objectForKey:@"color"];
                CGContextSetFillColorWithColor(ctx, beaconColor.CGColor);
            }
            CGContextFillRect(ctx, CGRectMake(myPoint.x - 5,myPoint.y - 5,width,width));
        }
        
        
    } //end configuration steps
    else {
        self.actionLabel.text = @"OK: configuration done";
    }
    
    //Ya plus qu'à mettre l'image dans le UIImage
    self.drawingView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    //et on arrête le contexte
    UIGraphicsEndImageContext();
    
    
}




- (CGPoint)trilaterate
{
    
    
        
        // on récupère toutes les données utiles
    
        NSDictionary * beacon1 = [self.beaconsData objectAtIndex:0];
        NSNumber * radius1Num = [beacon1 objectForKey:@"radius"];

        CGPoint point1 = [[beacon1 objectForKey:@"point"] CGPointValue];
        NSArray *beaconLocation1 = [NSArray arrayWithObjects:[NSNumber numberWithFloat:point1.x],[NSNumber numberWithFloat:point1.y],nil];
    
        NSDictionary * beacon2 = [self.beaconsData objectAtIndex:1];
        NSNumber * radius2Num = [beacon2 objectForKey:@"radius"];
        CGPoint point2 = [[beacon2 objectForKey:@"point"] CGPointValue];
        NSArray *beaconLocation2 = [NSArray arrayWithObjects:[NSNumber numberWithFloat:point2.x],[NSNumber numberWithFloat:point2.y],nil];
    
        NSDictionary * beacon3 = [self.beaconsData objectAtIndex:2];
        NSNumber * radius3Num = [beacon3 objectForKey:@"radius"];
        CGPoint point3 = [[beacon3 objectForKey:@"point"] CGPointValue];
        NSArray *beaconLocation3 = [NSArray arrayWithObjects:[NSNumber numberWithFloat:point3.x],[NSNumber numberWithFloat:point3.y],nil];
    NSLog(@"positions: %@  --- %@ --- %@",beaconLocation1,beaconLocation2,beaconLocation3);
    NSLog(@"radius: %@  --- %@ --- %@",radius1Num,radius2Num,radius3Num);
    
    
    //Voici l'algorithme en lui même
    
    float xa = [[NSNumber numberWithFloat:point1.x] floatValue];
    float ya = [[NSNumber numberWithFloat:point1.y] floatValue];
    float xb = [[NSNumber numberWithFloat:point2.x] floatValue];
    float yb = [[NSNumber numberWithFloat:point2.y] floatValue];
    float xc = [[NSNumber numberWithFloat:point3.x] floatValue];
    float yc = [[NSNumber numberWithFloat:point3.y] floatValue];
    float ra = [radius1Num floatValue];
    float rb = [radius2Num floatValue];
    float rc = [radius3Num floatValue];
 
    
    NSLog(@"%f,%f,%f,%f,%f,%f,%f,%f,%f",xa ,ya,xb,yb,xc,yc,ra,rb,rc);
    
    
    float S = (pow(xc, 2.) - pow(xb, 2.) + pow(yc, 2.) - pow(yb, 2.) + pow(rb, 2.) - pow(rc, 2.)) / 2.0;
    float T = (pow(xa, 2.) - pow(xb, 2.) + pow(ya, 2.) - pow(yb, 2.) + pow(rb, 2.) - pow(ra, 2.)) / 2.0;
    float y = ((T * (xb - xc)) - (S * (xb - xa))) / (((ya - yb) * (xb - xc)) - ((yc - yb) * (xb - xa)));
    
    float num =((T * (xb - xc)) - (S * (xb - xa)));
    float den = (((ya - yb) * (xb - xc)) - ((yc - yb) * (xb - xa)));
    
    NSLog(@"S: %f",S);
    NSLog(@"T: %f",T);
    NSLog(@"num: %f, den:%f",num,den);
    float x = ((y * (ya - yb)) - T) / (xb - xa);
    
    NSLog(@"x: %f,y: %f",x,y);
    
    CGPoint point = CGPointMake(x, y);
    return point;
}
    
    
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
