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
    FitbitAuthHandler *fitbitAuthHandler;
    __weak IBOutlet UISwitch *HeartProfileSwitch;
    __weak IBOutlet UISwitch *SleepProfileSwitch;
    __weak IBOutlet UISwitch *StepsProfileSwitch;
}

@end
