//
//  Core.m
//  BeaconConfigurator
//
//  Created by Khaos Tian on 7/29/13.
//  Copyright (c) 2013 Oltica. All rights reserved.
//

#import "Core.h"

@interface Core (){
    CBCentralManager *_centralManager;
    
    NSMutableArray   *_discoveredBeacons;
    
    CBPeripheral     *_connectedBeacon;
    
    CBCharacteristic *_uuidCharacteristic;
    CBCharacteristic *_major_minorCharacteristic;
    CBCharacteristic *_powerCharacteristic;
    CBCharacteristic *_rebootCharacteristic;
    
    NSString         *_beaconUUID;
    UInt16           _beaconMajor;
    UInt16           _beaconMinor;
    UInt8            _beaconPower;
    
    int              _changeCounter;
    BOOL             _canDisconnectFromCurrentBeacon;
}

@end

@implementation Core

+ (Core *)defaultCore
{
    static Core *defaultCore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultCore = [[self alloc]init];
    });
    return defaultCore;
}

- (id)init
{
    if (self = [super init]) {
        _changeCounter = 0;
        _centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:dispatch_queue_create("org.oltica.beaconconfigurator.queue", DISPATCH_QUEUE_SERIAL)];
        _discoveredBeacons = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)startScan
{
    [_centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"D8F7AC58-823C-4FA3-8CE5-7D5252D8FFF0"]] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : [NSNumber numberWithBool:YES]}];
}

- (NSArray *)discoveredBeacons
{
    return _discoveredBeacons;
}

- (NSNumber *)numberFromString:(NSString *)string
{
    unsigned char data[2];
    [[string dataUsingEncoding:NSUTF8StringEncoding]getBytes:data];
    UInt16 number = (data[0]-0x30) << 8 | (data[1]-0x30);
    return [NSNumber numberWithInt:number];
}

- (NSString *)currentBeaconUUID
{
    if (_beaconUUID != nil) {
        return _beaconUUID;
    }
    return 0;
}

- (NSNumber *)currentBeaconMajor
{
    return [NSNumber numberWithInt:_beaconMajor];
}

- (NSNumber *)currentBeaconMinor{
    return [NSNumber numberWithInt:_beaconMinor];
}

- (NSNumber *)currentBeaconPower
{
    return [NSNumber numberWithInt:_beaconPower-256];
}

- (void)connectBeaconAtIndex:(NSInteger)index
{
    [_centralManager stopScan];
    [_centralManager connectPeripheral:[_discoveredBeacons objectAtIndex:index] options:nil];
}

- (void)disconnectCurrentBeacon
{
    _canDisconnectFromCurrentBeacon = YES;
    if (_changeCounter <= 0 && _canDisconnectFromCurrentBeacon) {
        [self cancelConnectFromCurrentBeacon];
    }
}

- (void)cancelConnectFromCurrentBeacon
{
    NSData *rebootCommand = [NSData dataWithBytes:"\xFA" length:1];
    [_connectedBeacon writeValue:rebootCommand forCharacteristic:_rebootCharacteristic type:CBCharacteristicWriteWithResponse];

    _beaconUUID = nil;
    _beaconPower = 0;
    _beaconMajor = 0;
    _beaconMinor = 0;
    //[_centralManager cancelPeripheralConnection:_connectedBeacon];
    [self startScan];
}

- (void)setBeaconUUID:(NSString *)uuid
{
    CBUUID *pendingUUID;
    
    @try {
        pendingUUID = [CBUUID UUIDWithString:uuid];
        _beaconUUID = uuid;
    }
    @catch (NSException *exception) {
        NSLog(@"Error");
        return;
    }
    _changeCounter = _changeCounter + 1;
    [_connectedBeacon writeValue:pendingUUID.data forCharacteristic:_uuidCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void)setBeaconMajor:(NSNumber *)major AndMinor:(NSNumber *)minor
{
    int pendingMajor = major.intValue;
    if ((pendingMajor < 0) || (pendingMajor > 65535)) {
        NSLog(@"ValueError");
        return;
    }else{
        _beaconMajor = pendingMajor;

    }
    int pendingMinor = minor.intValue;
    if ((pendingMinor < 0) || (pendingMinor > 65535)) {
        NSLog(@"ValueError");
        return;
    }else{
        _beaconMinor = pendingMinor;
    }
    _changeCounter = _changeCounter + 1;
    uint8_t buf[] = {0x00 , 0x00 , 0x00 , 0x00};
    buf[3] =  (unsigned int) (pendingMinor & 0xff);
    buf[2] =  (unsigned int) (pendingMinor>>8 & 0xff);
    buf[1] =  (unsigned int) (pendingMajor & 0xff);
    buf[0] =  (unsigned int) (pendingMajor>>8 & 0xff);
    NSData *data = [[NSData alloc] initWithBytes:buf length:4];
    [_connectedBeacon writeValue:data forCharacteristic:_major_minorCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void)setBeaconPower:(NSNumber *)power
{
    int pendingPower = power.intValue;
    if ((pendingPower > -1) || (pendingPower < -256)) {
        NSLog(@"Error");
        return;
    }else{
        _changeCounter = _changeCounter + 1;
        pendingPower = pendingPower + 256;
        uint8_t buf[] = {0x00};
        buf[0] = pendingPower;
        NSData *data = [[NSData alloc] initWithBytes:buf length:1];
        [_connectedBeacon writeValue:data forCharacteristic:_powerCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

#pragma mark - CBCentralManagerDelegate & CBPeripheralDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            [self startScan];
            break;
            
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if (![_discoveredBeacons containsObject:peripheral]) {
        [_discoveredBeacons insertObject:peripheral atIndex:0];
        if ([_delegate respondsToSelector:@selector(didDiscoverNewBeacon)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate didDiscoverNewBeacon];
            });
        }
    }
    if ([_delegate respondsToSelector:@selector(updateRSSIForPeripheral:RSSI:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate updateRSSIForPeripheral:peripheral RSSI:RSSI];
        });
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    _changeCounter = 0;
    _canDisconnectFromCurrentBeacon = NO;
    _connectedBeacon = peripheral;
    [peripheral setDelegate:self];
    [peripheral discoverServices:@[[CBUUID UUIDWithString:@"FFF0"]]];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if ([_discoveredBeacons containsObject:peripheral]) {
        [_discoveredBeacons removeObject:peripheral];
    }
    if ([peripheral isEqual:_connectedBeacon]) {
        _connectedBeacon = nil;
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService *aService in peripheral.services) {
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"FFF0"]]) {
            [peripheral discoverCharacteristics:nil forService:aService];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic *aChar in service.characteristics) {
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FFF1"]]) {
            _uuidCharacteristic = aChar;
            [peripheral readValueForCharacteristic:aChar];
            continue;
        }
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FFF2"]]) {
            _major_minorCharacteristic = aChar;
            [peripheral readValueForCharacteristic:aChar];
            continue;
        }
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FFF3"]]) {
            _powerCharacteristic = aChar;
            [peripheral readValueForCharacteristic:aChar];
            continue;
        }
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"FFF4"]]) {
            _rebootCharacteristic = aChar;
            continue;
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error:%@",error);
        return;
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFF1"]]) {
        NSString *temp = [self getHexString:characteristic.value];
        
        NSRange r1 = NSMakeRange(8, 4);
        NSRange r2 = NSMakeRange(12, 4);
        NSRange r3 = NSMakeRange(16, 4);
        
        _beaconUUID = [temp substringToIndex:8];
        _beaconUUID = [_beaconUUID stringByAppendingString:@"-"];
        _beaconUUID = [_beaconUUID stringByAppendingString:[temp substringWithRange:r1]];
        _beaconUUID = [_beaconUUID stringByAppendingString:@"-"];
        _beaconUUID = [_beaconUUID stringByAppendingString:[temp substringWithRange:r2]];
        _beaconUUID = [_beaconUUID stringByAppendingString:@"-"];
        _beaconUUID = [_beaconUUID stringByAppendingString:[temp substringWithRange:r3]];
        _beaconUUID = [_beaconUUID stringByAppendingString:@"-"];
        _beaconUUID = [_beaconUUID stringByAppendingString:[temp substringFromIndex:20]];
        _beaconUUID = [_beaconUUID uppercaseString];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"DidUpdateBeaconUUID" object:nil];
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFF2"]]) {
        unsigned char data[4];
        [characteristic.value getBytes:data length:4];
        _beaconMajor = data[0] << 8 | data[1];
        _beaconMinor = data[2] << 8 | data[3];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"DidUpdateBeaconMajor" object:nil];
    }
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFF3"]]) {
        unsigned char data[1];
        [characteristic.value getBytes:data length:1];
        
        _beaconPower = data[0];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"DidUpdateBeaconPower" object:nil];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    _changeCounter = _changeCounter - 1;
    if (_changeCounter <= 0 && _canDisconnectFromCurrentBeacon) {
        [self cancelConnectFromCurrentBeacon];
    }
}

#pragma mark - Tools

-(NSString*)getHexString:(NSData*)data {
    NSUInteger dataLength = [data length];
    NSMutableString *string = [NSMutableString stringWithCapacity:dataLength*2];
    const unsigned char *dataBytes = [data bytes];
    for (NSInteger idx = 0; idx < dataLength; ++idx) {
        [string appendFormat:@"%02x", dataBytes[idx]];
    }
    return string;
}

@end
