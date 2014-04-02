//
//  DetailViewController.m
//  BeaconConfigurator
//
//  Created by Khaos Tian on 7/29/13.
//  Copyright (c) 2013 Oltica. All rights reserved.
//

#import "DetailViewController.h"
#import "Core.h"

@interface DetailViewController (){
    id _DidUpdateBeaconUUID;
    id _DidUpdateBeaconMajor;
    id _DidUpdateBeaconPower;
    
    BOOL _UUIDVerified;
    BOOL _MajorVerified;
    BOOL _MinorVerified;
    BOOL _PowerVerified;
}
- (void)configureView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    
}

- (void)configureView
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    _UUIDField.delegate = self;
    _MajorField.delegate = self;
    _MinorField.delegate = self;
    _PowerField.delegate = self;
    _UUIDVerified = YES;
    _MajorVerified = YES;
    _MinorVerified = YES;
    _PowerVerified = YES;
    // Update the user interface for the detail item.

}

- (void)dismissKeyboard
{
    [_UUIDField resignFirstResponder];
    [_MajorField resignFirstResponder];
    [_MinorField resignFirstResponder];
    [_PowerField resignFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    _DidUpdateBeaconUUID = [[NSNotificationCenter defaultCenter]addObserverForName:@"DidUpdateBeaconUUID" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        _UUIDField.text = [[Core defaultCore]currentBeaconUUID];
    }];
    _DidUpdateBeaconMajor = [[NSNotificationCenter defaultCenter]addObserverForName:@"DidUpdateBeaconMajor" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        _MajorField.text = [[Core defaultCore]currentBeaconMajor].stringValue;
        _MinorField.text = [[Core defaultCore]currentBeaconMinor].stringValue;
    }];
    _DidUpdateBeaconPower = [[NSNotificationCenter defaultCenter]addObserverForName:@"DidUpdateBeaconPower" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        _PowerField.text = [[Core defaultCore]currentBeaconPower].stringValue;
    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:_DidUpdateBeaconUUID];
    [[NSNotificationCenter defaultCenter]removeObserver:_DidUpdateBeaconMajor];
    [[NSNotificationCenter defaultCenter]removeObserver:_DidUpdateBeaconPower];
    _DidUpdateBeaconUUID = nil;
    _DidUpdateBeaconMajor = nil;
    _DidUpdateBeaconPower = nil;
    [[Core defaultCore]disconnectCurrentBeacon];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)saveSettings:(id)sender {
    if (![_UUIDField.text isEqualToString:[[Core defaultCore] currentBeaconUUID]]) {
        [[Core defaultCore]setBeaconUUID:_UUIDField.text];
    }
    if ((![_MajorField.text isEqualToString:[[[Core defaultCore]currentBeaconMajor]stringValue]])||(![_MinorField.text isEqualToString:[[[Core defaultCore]currentBeaconMinor]stringValue]])) {
        [[Core defaultCore]setBeaconMajor:[NSNumber numberWithInteger:_MajorField.text.integerValue] AndMinor:[NSNumber numberWithInteger:_MinorField.text.integerValue]];
    }
    if (![_PowerField.text isEqualToString:[[[Core defaultCore]currentBeaconPower]stringValue]]) {
        [[Core defaultCore]setBeaconPower:[NSNumber numberWithInteger:_PowerField.text.integerValue]];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)endUUIDEdit:(id)sender {
    if (![_UUIDField.text isEqualToString:[[Core defaultCore] currentBeaconUUID]]) {
        CBUUID *pendingUUID;
        
        @try {
            pendingUUID = [CBUUID UUIDWithString:_UUIDField.text];
        }
        @catch (NSException *exception) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Invalid UUID" message:@"It seems you entered an uuid number that is invalid." delegate:self cancelButtonTitle:@"Edit" otherButtonTitles:@"Dismiss", nil];
            alert.tag = 1;
            [alert show];
            _UUIDVerified = NO;
            [self checkStatus];
            return;
        }
        _UUIDVerified = YES;
        [self checkStatus];
    }
}

- (IBAction)endMajorEdit:(id)sender {
    if (![_MajorField.text isEqualToString:[[[Core defaultCore]currentBeaconMajor]stringValue]]) {
        if ((_MajorField.text.intValue < 0) || (_MajorField.text.intValue > 65535)) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Invalid Major" message:@"It seems you entered a major number that is invalid." delegate:self cancelButtonTitle:@"Edit" otherButtonTitles:@"Dismiss", nil];
            alert.tag = 2;
            [alert show];
            _MajorVerified = NO;
            [self checkStatus];
        }else{
            _MajorVerified = YES;
            [self checkStatus];
        }
    }
}

- (IBAction)endMinorEdit:(id)sender {
    if (![_MinorField.text isEqualToString:[[[Core defaultCore]currentBeaconMinor]stringValue]]) {
        if ((_MinorField.text.intValue < 0) || (_MinorField.text.intValue > 65535)) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Invalid Minor" message:@"It seems you entered a minor number that is invalid." delegate:self cancelButtonTitle:@"Edit" otherButtonTitles:@"Dismiss", nil];
            alert.tag = 3;
            [alert show];
            _MinorVerified = NO;
            [self checkStatus];
        }else{
            _MinorVerified = YES;
            [self checkStatus];
        }
    }
}

- (IBAction)endPowerEdit:(id)sender {
    if (![_PowerField.text isEqualToString:[[[Core defaultCore]currentBeaconPower]stringValue]]) {
        if ((_PowerField.text.intValue > -1) || (_PowerField.text.intValue < -256)) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Invalid Power" message:@"It seems you entered a power number that is invalid." delegate:self cancelButtonTitle:@"Edit" otherButtonTitles:@"Dismiss", nil];
            alert.tag = 4;
            [alert show];
            _PowerVerified = NO;
            [self checkStatus];
        }else{
            _PowerVerified = YES;
            [self checkStatus];
        }
    }
}

- (void)checkStatus
{
    if (_UUIDVerified && _MajorVerified && _MinorVerified && _PowerVerified) {
        [UIView animateWithDuration:0.33 animations:^{
            _saveButton.hidden = NO;
        }];
    }else{
        [UIView animateWithDuration:0.33 animations:^{
            _saveButton.hidden = YES;
        }];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 1:
        {
            if (buttonIndex == 0) {
                [_UUIDField becomeFirstResponder];
            }
            if (buttonIndex == 1) {
                _UUIDField.text = [[Core defaultCore]currentBeaconUUID];
                _UUIDVerified = YES;
                [self checkStatus];
            }
        }
            break;
            
        case 2:
        {
            if (buttonIndex == 0) {
                [_MajorField becomeFirstResponder];
            }
            if (buttonIndex == 1) {
                _MajorField.text = [[Core defaultCore]currentBeaconMajor].stringValue;
                _MajorVerified = YES;
                [self checkStatus];
            }
        }
            break;
            
        case 3:
        {
            if (buttonIndex == 0) {
                [_MinorField becomeFirstResponder];
            }
            if (buttonIndex == 1) {
                _MinorField.text = [[Core defaultCore]currentBeaconMinor].stringValue;
                _MinorVerified = YES;
                [self checkStatus];
            }
        }
            break;
            
        case 4:
        {
            if (buttonIndex == 0) {
                [_PowerField becomeFirstResponder];
            }
            if (buttonIndex == 1) {
                _PowerField.text = [[Core defaultCore]currentBeaconPower].stringValue;
                _PowerVerified = YES;
                [self checkStatus];
            }
        }
            break;
            
        default:
            break;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

@end
