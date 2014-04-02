//
//  Core.h
//  BeaconConfigurator
//
//  Created by Khaos Tian on 7/29/13.
//  Copyright (c) 2013 Oltica. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol CoreManagerDelegate <NSObject>

@optional
- (void)didDiscoverNewBeacon;
- (void)updateRSSIForPeripheral:(CBPeripheral *)peripheral RSSI:(NSNumber *)rssi;
@end

@interface Core : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>

@property (weak,nonatomic) id delegate;

+ (Core *)defaultCore;

- (void)connectBeaconAtIndex:(NSInteger)index;
- (void)disconnectCurrentBeacon;

- (void)setBeaconUUID:(NSString *)uuid;
- (void)setBeaconMajor:(NSNumber *)major AndMinor:(NSNumber *)minor;
- (void)setBeaconPower:(NSNumber *)power;

- (NSArray *)discoveredBeacons;
- (NSNumber *)numberFromString:(NSString *)string;

- (NSString *)currentBeaconUUID;
- (NSNumber *)currentBeaconMajor;
- (NSNumber *)currentBeaconMinor;
- (NSNumber *)currentBeaconPower;

@end
