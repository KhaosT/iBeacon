//
//  DetailViewController.h
//  BeaconConfigurator
//
//  Created by Khaos Tian on 7/29/13.
//  Copyright (c) 2013 Oltica. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController<UITextFieldDelegate,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *UUIDField;
@property (weak, nonatomic) IBOutlet UITextField *MajorField;
@property (weak, nonatomic) IBOutlet UITextField *MinorField;
@property (weak, nonatomic) IBOutlet UITextField *PowerField;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;


- (IBAction)saveSettings:(id)sender;
- (IBAction)endUUIDEdit:(id)sender;
- (IBAction)endMajorEdit:(id)sender;
- (IBAction)endMinorEdit:(id)sender;
- (IBAction)endPowerEdit:(id)sender;

@end
