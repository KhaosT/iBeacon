//
//  MasterViewController.m
//  BeaconConfigurator
//
//  Created by Khaos Tian on 7/29/13.
//  Copyright (c) 2013 Oltica. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "BeaconInfoCell.h"
@interface MasterViewController (){
    int         _reloadCount;
}

@end

@implementation MasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    _reloadCount = 0;
    [super viewDidLoad];
    [Core defaultCore].delegate = self;
    [self.tableView registerClass:[BeaconInfoCell class] forCellReuseIdentifier:@"Cell"];
	// Do any additional setup after loading the view, typically from a nib.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)didDiscoverNewBeacon
{
    [self.tableView reloadData];
    //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    //[self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)updateRSSIForPeripheral:(CBPeripheral *)peripheral RSSI:(NSNumber *)rssi
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[[[Core defaultCore]discoveredBeacons]indexOfObject:peripheral] inSection:0];
    _reloadCount ++;
    if (_reloadCount > 30) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        _reloadCount = 0;
    }
    BeaconInfoCell *cell = (BeaconInfoCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    cell.rssiLabel.text = [rssi description];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[Core defaultCore] discoveredBeacons].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BeaconInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    CBPeripheral *peripheral = [[Core defaultCore]discoveredBeacons][indexPath.row];
    cell.nameLabel.text = peripheral.name;
    cell.rssiLabel.text = peripheral.RSSI.stringValue;
    if (peripheral.name.length == 11) {
        cell.majorLabel.text = [NSString stringWithFormat:@"Major:%@",[[Core defaultCore]numberFromString:[peripheral.name substringWithRange:NSMakeRange(7, 2)]]];
        cell.minorLabel.text = [NSString stringWithFormat:@"Minor:%@",[[Core defaultCore]numberFromString:[peripheral.name substringWithRange:NSMakeRange(9, 2)]]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[Core defaultCore]connectBeaconAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"showDetail" sender:self];
}

/*- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

@end
