//
//  SettingsViewController.m
//  SampleBit
//
//  Created by Robert Balmbra on 01/11/2018.
//  Copyright © 2018 insanelydeepak. All rights reserved.
//

#import "ViewController.h"
#import "FitbitExplorer.h"
@interface SettingsViewController : UITableViewController

@end

@implementation SettingsViewController
{
    __weak IBOutlet UISwitch *HeartProfileSwitch;
    __weak IBOutlet UISwitch *SleepProfileSwitch;
    __weak IBOutlet UISwitch *StepsProfileSwitch;
    __weak IBOutlet UISwitch *DistanceProfileSwitch;
    __weak IBOutlet UISwitch *FloorProfileSwitch;
    FitbitAuthHandler *fitbitAuthHandler;
}

- (IBAction)HRSwitch:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:@"heartSwitch"];
}

- (IBAction)SleepSwitch:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:@"sleepSwitch"];
}

- (IBAction)StepSwitch:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:@"stepSwitch"];
}

- (IBAction)DistanceSwitch:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:@"distanceSwitch"];
}

- (IBAction)FloorSwitch:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:@"floorSwitch"];
}

-(void)viewWillAppear:(BOOL)animated
{
    // Heart Rate Switch
    BOOL switchState = [[NSUserDefaults standardUserDefaults] boolForKey:@"heartSwitch"];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"heartSwitch"] == nil) {
        [HeartProfileSwitch setOn:YES];
    }else  if (switchState == false) {
        [HeartProfileSwitch setOn:NO];
    }else{
        [HeartProfileSwitch setOn:YES];
    }
    
    // Sleep Switch
    switchState = [[NSUserDefaults standardUserDefaults] boolForKey:@"sleepSwitch"];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"sleepSwitch"] == nil) {
        [SleepProfileSwitch setOn:YES];
    }else if (switchState == false) {
        [SleepProfileSwitch setOn:NO];
    }else{
        [SleepProfileSwitch setOn:YES];
    }
    
    // Step Switch
    switchState = [[NSUserDefaults standardUserDefaults] boolForKey:@"stepSwitch"];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"stepSwitch"] == nil) {
        [StepsProfileSwitch setOn:YES];
    }else if (switchState == false) {
        [StepsProfileSwitch setOn:NO];
    }else{
        [StepsProfileSwitch setOn:YES];
    }
    
    // Distance Switch
    switchState = [[NSUserDefaults standardUserDefaults] boolForKey:@"distanceSwitch"];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"distanceSwitch"] == nil) {
        [DistanceProfileSwitch setOn:YES];
    }else if (switchState == false) {
        [DistanceProfileSwitch setOn:NO];
    }else{
        [DistanceProfileSwitch setOn:YES];
    }

    // Floors Switch
    switchState = [[NSUserDefaults standardUserDefaults] boolForKey:@"floorSwitch"];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"floorSwitch"] == nil) {
        [FloorProfileSwitch setOn:YES];
    }else if (switchState == false) {
        [FloorProfileSwitch setOn:NO];
    }else{
        [FloorProfileSwitch setOn:YES];
    }
}

@end

