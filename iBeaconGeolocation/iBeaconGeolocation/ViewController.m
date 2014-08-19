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
    NSDictionary *beacon1 = @{
                                @"key": @"",
                                @"point":[NSValue valueWithCGPoint:CGPointMake(10.f,500.f)],
                                @"color":[UIColor colorWithRed:0.5 green:0 blue:0.3 alpha:1.0],
                                @"num":@0
                            };
    [self.beaconsData setObject:[beacon1 mutableCopy] atIndexedSubscript:[self.beaconsData count]];
    
    
    NSDictionary *beacon2 = @{
                                @"key": @"",
                                @"point":[NSValue valueWithCGPoint:CGPointMake(10.f,350.f)],
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
    NSLog(@"ranging");
    int step = [self.step intValue];
    if(step <=3) {
        
        for(CLBeacon *beacon in beacons) {
            NSString *beaconKey = [NSString stringWithFormat:@"%@_%@",beacon.major,beacon.minor];
            if (beacon.proximity == CLProximityImmediate) {
                
                NSLog(@"beacon found with immediate proximity");
                //We check that the beacon is not already registered
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
    else {
        //we empty the canvas
        UIGraphicsBeginImageContext(self.view.frame.size);
        [self.drawingView.image drawInRect:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextClearRect(ctx, CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height));
        
        //We draw the beacons
        for(int i=0;i<=2;i++) {
            NSMutableDictionary *beacon = [self.beaconsData objectAtIndex:i];
            
            CGPoint myPoint = [[beacon objectForKey:@"point"] CGPointValue];
            
            int width = 10;

            UIColor *beaconColor = [beacon objectForKey:@"color"];
            CGContextSetFillColorWithColor(ctx, beaconColor.CGColor);
            
            CGContextFillRect(ctx, CGRectMake(myPoint.x - 5,myPoint.y - 5,width,width));
        }
        //We draw the circles
        //We store the accuracy for trilateration
        
        
        NSMutableArray *ratioList = [[NSMutableArray alloc] initWithCapacity:3];
        ratioList[0] =[NSNumber numberWithDouble:1.0f];
        ratioList[1] =[NSNumber numberWithDouble:1.0f];
        ratioList[2] =[NSNumber numberWithDouble:1.0f];
        //We calculate the ratio to have the different beacons radius crossing
        for(CLBeacon *beacon in beacons) {
            NSString *beaconKey = [NSString stringWithFormat:@"%@_%@",beacon.major,beacon.minor];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@", beaconKey];
            NSArray *elem = [self.beaconsData filteredArrayUsingPredicate:predicate];
            if([elem count] !=1) {
                NSLog(@"beacon not found");
                continue;
            }
            NSDictionary *beaconData = [elem objectAtIndex:0];
            NSString *num = [beaconData valueForKey:@"num"];
            int number = [num intValue];
           // [ratioList setObject:[NSNumber numberWithDouble:beacon.accuracy] ];
            ratioList[number] =[NSNumber numberWithDouble:beacon.accuracy];
        }
        NSLog(@"ratio list %@",ratioList);
        float accuracy0 = [ratioList[0] floatValue];
        float accuracy1 = [ratioList[1] floatValue];
        float accuracy2 = [ratioList[2] floatValue];
        
        float distance01 = accuracy0+accuracy1;
        float distance02 = accuracy0+accuracy2;
        float distance12 = accuracy1+accuracy2;
        
        float ratio01 = 150.f/distance01;
        float ratio02 = 150.f/distance02;
        float ratio12 = 212.13f/distance12;
        
        float ratio = MAX(MAX(ratio01,ratio02),ratio12);
        
        NSMutableDictionary *radiusList = [[NSMutableDictionary alloc] init];
        
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
            
            CGContextBeginPath(ctx);
            CGContextSetLineWidth(ctx, 1);
            CGContextSetStrokeColorWithColor(ctx, color.CGColor);
            CGContextAddArc(ctx, center.x, center.y, radius, 0, 2*M_PI, 0);
            CGContextStrokePath(ctx);
            
        } //end foreach beacon ranged
        
        
        
        for(int i=0;i<=2;i++) {
            NSMutableDictionary *beacon = [self.beaconsData objectAtIndex:i];
            [beacon setObject:[radiusList objectForKey:[beacon objectForKey:@"key"]] forKey:@"radius"];
            [self.beaconsData setObject:beacon atIndexedSubscript:i];
        }
        
        //et on calcule les coordonnées du téléphone
/*        NSArray *coordinates = [self trilaterate];
        float x = [[coordinates objectAtIndex:0] floatValue];
        float y = [[coordinates objectAtIndex:1] floatValue];
        
        CGContextSetFillColorWithColor(ctx, [UIColor redColor].CGColor);
        CGContextFillRect(ctx, CGRectMake(x,y,20,20));
*/
        //Ya plus qu'à mettre l'image dans le UIImage
        self.drawingView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    } //end stpe > 3
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
        
        /*
        CGPoint center = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0);
        CGContextBeginPath(ctx);
        CGContextSetLineWidth(ctx, 1);
        CGContextAddArc(ctx, center.x, center.y, 200.0, 0, 2*M_PI, 0);
        CGContextStrokePath(ctx);
        */
        
        
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




- (NSArray *)trilaterate
{
    NSString *error = @"";
    NSArray *coordinates;

    
        
        
        // PROCEED TRILATERATION
        
        // get coordinates for each beacon, minor is used to identify
    
        NSDictionary * beacon1 = [self.beaconsData objectAtIndex:0];
        NSNumber * radius1Num = [beacon1 objectForKey:@"radius"];
        double radius1 = [radius1Num doubleValue];
        CGPoint point1 = [[beacon1 objectForKey:@"point"] CGPointValue];
        NSArray *beaconLocation1 = [NSArray arrayWithObjects:[NSNumber numberWithFloat:point1.x],[NSNumber numberWithFloat:point1.y],nil];
    
        NSDictionary * beacon2 = [self.beaconsData objectAtIndex:1];
        NSNumber * radius2Num = [beacon2 objectForKey:@"radius"];
        double radius2 = [radius2Num doubleValue];
        CGPoint point2 = [[beacon2 objectForKey:@"point"] CGPointValue];
        NSArray *beaconLocation2 = [NSArray arrayWithObjects:[NSNumber numberWithFloat:point2.x],[NSNumber numberWithFloat:point2.y],nil];
    
        NSDictionary * beacon3 = [self.beaconsData objectAtIndex:2];
        NSNumber * radius3Num = [beacon3 objectForKey:@"radius"];
        double radius3 = [radius3Num doubleValue];
        CGPoint point3 = [[beacon2 objectForKey:@"point"] CGPointValue];
        NSArray *beaconLocation3 = [NSArray arrayWithObjects:[NSNumber numberWithFloat:point3.x],[NSNumber numberWithFloat:point3.y],nil];
    NSLog(@"positions: %@  --- %@ --- %@",beaconLocation1,beaconLocation2,beaconLocation3);
            // ex = (P2 - P1)/(numpy.linalg.norm(P2 - P1))
            NSMutableArray *ex = [[NSMutableArray alloc] initWithCapacity:0];
            double temp = 0;
            for (int i = 0; i < [beaconLocation1 count]; i++) {
                double t1 = [[beaconLocation2 objectAtIndex:i] doubleValue];
                double t2 = [[beaconLocation1 objectAtIndex:i] doubleValue];
                double t = t1 - t2;
                temp += (t*t);
            }
            for (int i = 0; i < [beaconLocation1 count]; i++) {
                double t1 = [[beaconLocation2 objectAtIndex:i] doubleValue];
                double t2 = [[beaconLocation1 objectAtIndex:i] doubleValue];
                double exx = (t1 - t2)/sqrt(temp);
                [ex addObject:[NSNumber numberWithDouble:exx]];
            }
    NSLog(@"ex: %@",ex);
    
            // i = dot(ex, P3 - P1)
            NSMutableArray *p3p1 = [[NSMutableArray alloc] initWithCapacity:0];
            for (int i = 0; i < [beaconLocation3 count]; i++) {
                double t1 = [[beaconLocation3 objectAtIndex:i] doubleValue];
                double t2 = [[beaconLocation1 objectAtIndex:i] doubleValue];
                double t3 = t1 - t2;
                [p3p1 addObject:[NSNumber numberWithDouble:t3]];
            }
    NSLog(@"p3p1: %@",p3p1);
            double ival = 0;
            for (int i = 0; i < [ex count]; i++) {
                double t1 = [[ex objectAtIndex:i] doubleValue];
                double t2 = [[p3p1 objectAtIndex:i] doubleValue];
                ival += (t1*t2);
            }
    NSLog(@"ival: %f",ival);
    
            // ey = (P3 - P1 - i*ex)/(numpy.linalg.norm(P3 - P1 - i*ex))
            NSMutableArray *ey = [[NSMutableArray alloc] initWithCapacity:0];
            double p3p1i = 0;
            for (int  i = 0; i < [beaconLocation3 count]; i++) {
                double t1 = [[beaconLocation3 objectAtIndex:i] doubleValue];
                double t2 = [[beaconLocation1 objectAtIndex:i] doubleValue];
                double t3 = [[ex objectAtIndex:i] doubleValue] * ival;
                double t = t1 - t2 -t3;
                p3p1i += (t*t);
            }
            for (int i = 0; i < [beaconLocation3 count]; i++) {
                double t1 = [[beaconLocation3 objectAtIndex:i] doubleValue];
                double t2 = [[beaconLocation1 objectAtIndex:i] doubleValue];
                double t3 = [[ex objectAtIndex:i] doubleValue] * ival;
                double eyy = (t1 - t2 - t3)/sqrt(p3p1i);
                [ey addObject:[NSNumber numberWithDouble:eyy]];
            }
     NSLog(@"ey: %@",ey);
            // ez = numpy.cross(ex,ey)
            // if 2-dimensional vector then ez = 0
            NSMutableArray *ez = [[NSMutableArray alloc] initWithCapacity:0];
            double ezx;
            double ezy;
            double ezz;

            ezx = 0;
            ezy = 0;
            ezz = 0;
            
            [ez addObject:[NSNumber numberWithDouble:ezx]];
            [ez addObject:[NSNumber numberWithDouble:ezy]];
            [ez addObject:[NSNumber numberWithDouble:ezz]];
            
            // d = numpy.linalg.norm(P2 - P1)
            double d = sqrt(temp);
     NSLog(@"d: %f",d);
            // j = dot(ey, P3 - P1)
            double jval = 0;
            for (int i = 0; i < [ey count]; i++) {
                double t1 = [[ey objectAtIndex:i] doubleValue];
                double t2 = [[p3p1 objectAtIndex:i] doubleValue];
                jval += (t1*t2);
            }
            
            // x = (pow(DistA,2) - pow(DistB,2) + pow(d,2))/(2*d)
            double xval = (pow(radius1,2) - pow(radius2,2) + pow(d,2))/(2*d);
NSLog(@"xval: %f",xval);
            // y = ((pow(DistA,2) - pow(DistC,2) + pow(i,2) + pow(j,2))/(2*j)) - ((i/j)*x)
            double yval = ((pow(radius1,2) - pow(radius3,2) + pow(ival,2) + pow(jval,2))/(2*jval)) - ((ival/jval)*xval);
NSLog(@"yval: %f",yval);
            // z = sqrt(pow(DistA,2) - pow(x,2) - pow(y,2))
            // if 2-dimensional vector then z = 0
            double zval;
            zval = 0;

            
            // coord = P1 + x*ex + y*ey + z*ez
            NSMutableArray *trilateratedCoordinates = [[NSMutableArray alloc] initWithCapacity:0];
            for (int i = 0; i < [beaconLocation1 count]; i++) {
                double t1 = [[beaconLocation1 objectAtIndex:i] doubleValue];
                double t2 = [[ex objectAtIndex:i] doubleValue] * xval;
                double t3 = [[ey objectAtIndex:i] doubleValue] * yval;
                double t4 = [[ez objectAtIndex:i] doubleValue] * zval;
                double triptx = t1+t2+t3+t4;
                [trilateratedCoordinates addObject:[NSNumber numberWithDouble:triptx]];
                if (isnan(triptx))
                {
                    error = @"at least one of the calculated coordinates is NaN";
                }
            }
            coordinates = [trilateratedCoordinates copy];
            // if you want to store the used beacons to pass them on, uncomment line below
            //NSArray *usedBeacons = [[NSArray alloc] initWithObjects:beacon1, beacon2, beacon3, nil];

    
    self.actionLabel.text = error;
    NSLog(@"coordinates: %@",coordinates);
    return coordinates;
}
    
    
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
