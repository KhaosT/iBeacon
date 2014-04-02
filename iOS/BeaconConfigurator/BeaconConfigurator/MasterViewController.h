//
//  MasterViewController.h
//  BeaconConfigurator
//
//  Created by Khaos Tian on 7/29/13.
//  Copyright (c) 2013 Oltica. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Core.h"

@interface MasterViewController : UITableViewController<CoreManagerDelegate>

-(void)didDiscoverNewBeacon;
- (void)updateRSSIForPeripheral:(CBPeripheral *)peripheral RSSI:(NSNumber *)rssi;

@end
