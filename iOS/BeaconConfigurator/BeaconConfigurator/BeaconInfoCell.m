//
//  BeaconInfoCell.m
//  BeaconConfigurator
//
//  Created by Khaos Tian on 7/29/13.
//  Copyright (c) 2013 Oltica. All rights reserved.
//

#import "BeaconInfoCell.h"

@implementation BeaconInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 20, 150, 35)];
        _nameLabel.font = [UIFont systemFontOfSize:24.0];
        [self.contentView addSubview:_nameLabel];
        _rssiLabel = [[UILabel alloc]initWithFrame:CGRectMake(230, 30, 40, 18)];
        _rssiLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        [self.contentView addSubview:_rssiLabel];
        _majorLabel = [[UILabel alloc]initWithFrame:CGRectMake(12, 45, 80, 18)];
        _majorLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        [self.contentView addSubview:_majorLabel];
        _minorLabel = [[UILabel alloc]initWithFrame:CGRectMake(95, 45, 80, 18)];
        _minorLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
        [self.contentView addSubview:_minorLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
