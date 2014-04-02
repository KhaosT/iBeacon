//
//  BeaconInfoCell.h
//  BeaconConfigurator
//
//  Created by Khaos Tian on 7/29/13.
//  Copyright (c) 2013 Oltica. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BeaconInfoCell : UITableViewCell

@property (strong,nonatomic) UILabel *nameLabel;
@property (strong,nonatomic) UILabel *rssiLabel;
@property (strong,nonatomic) UILabel *majorLabel;
@property (strong,nonatomic) UILabel *minorLabel;

@end
