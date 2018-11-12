//
//  SettingsViewController.m
//  SampleBit
//
//  Created by Robert Balmbra on 01/11/2018.
//  Copyright © 2018 insanelydeepak. All rights reserved.
//

#import "SettingsViewController.h"
#import "FitbitExplorer.h"
@interface SettingsViewController ()

@end

@implementation SettingsViewController
{
    __weak IBOutlet UISwitch *HeartProfileSwitch;
    __weak IBOutlet UISwitch *SleepProfileSwitch;
    __weak IBOutlet UISwitch *StepsProfileSwitch;
    __weak IBOutlet UISwitch *DistanceProfileSwitch;
    __weak IBOutlet UISwitch *FloorProfileSwitch;
    __weak IBOutlet UISwitch *WaterProfileSwitch;
    __weak IBOutlet UISwitch *EnergyProfileSwitch;
    __weak IBOutlet UISwitch *NutrientsProfileSwitch;
    __weak IBOutlet UISwitch *WeightProfileSwitch;
    __weak IBOutlet UISwitch *DarkModeSwitch;
    __weak IBOutlet UITableView *settingsView;
    __weak IBOutlet UITableViewCell *syncsettings;
    __weak IBOutlet UIView *HeartRateSwitchUI;
    __weak IBOutlet UILabel *HeartRateSwitchText;
    __weak IBOutlet UIView *SleepSwitchUI;
    __weak IBOutlet UILabel *SleepSwitchText;
    __weak IBOutlet UIView *StepsSwitchUI;
    __weak IBOutlet UILabel *StepsSwitchText;
    __weak IBOutlet UIView *DistanceSwitchUI;
    __weak IBOutlet UILabel *DistanceSwitchText;
    __weak IBOutlet UIView *FloorsSwitchUI;
    __weak IBOutlet UILabel *FloorsSwitchText;
    __weak IBOutlet UIView *WeightSwitchUI;
    __weak IBOutlet UILabel *WeightSwitchText;
    __weak IBOutlet UIView *NutrientsSwitchUI;
    __weak IBOutlet UILabel *NutrientsSwitchText;
    __weak IBOutlet UILabel *EnergySwitchText;
    __weak IBOutlet UIView *EnergySwitchUI;
    __weak IBOutlet UILabel *WaterSwitchText;
    __weak IBOutlet UIView *WaterSwitchUI;
    __weak IBOutlet UIView *DarkModeSwitchUI;
    __weak IBOutlet UILabel *DarkModeSwitchText;
    __weak IBOutlet UITabBarItem *navigationBar;
    __weak IBOutlet UILabel *SettingsLabel;
    FitbitAuthHandler *fitbitAuthHandler;
}

- (IBAction)WaterSwitch:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:@"waterSwitch"];
}

- (IBAction)WeightSwitch:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:@"weightSwitch"];
}

- (IBAction)NutrientsSwitch:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:@"nutrientsSwitch"];
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

- (IBAction)EnergyBurnt:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:@"activeEnergy"];
}

- (IBAction)ProfileSwitch:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:@"DarkModeSwitch"];
    
    if(sender.isOn == true){
        // On
        self.view.backgroundColor = [UIColor blackColor];
        settingsView.backgroundColor = [UIColor blackColor];
        settingsView.backgroundView.backgroundColor = [UIColor blackColor];
        HeartRateSwitchUI.backgroundColor = [UIColor blackColor];
        HeartRateSwitchText.textColor = [UIColor whiteColor];
        SleepSwitchUI.backgroundColor = [UIColor blackColor];
        SleepSwitchText.textColor = [UIColor whiteColor];
        StepsSwitchUI.backgroundColor = [UIColor blackColor];
        StepsSwitchText.textColor = [UIColor whiteColor];
        DistanceSwitchUI.backgroundColor = [UIColor blackColor];
        DistanceSwitchText.textColor = [UIColor whiteColor];
        FloorsSwitchUI.backgroundColor = [UIColor blackColor];
        FloorsSwitchText.textColor = [UIColor whiteColor];
        DarkModeSwitchUI.backgroundColor = [UIColor blackColor];
        DarkModeSwitchText.textColor = [UIColor whiteColor];
        SettingsLabel.textColor = [UIColor whiteColor];
        NutrientsSwitchUI.backgroundColor = [UIColor blackColor];
        NutrientsSwitchText.textColor = [UIColor whiteColor];
        EnergySwitchUI.backgroundColor = [UIColor blackColor];
        EnergySwitchText.textColor = [UIColor whiteColor];
        WaterSwitchUI.backgroundColor = [UIColor blackColor];
        WaterSwitchText.textColor = [UIColor whiteColor];
        WeightSwitchUI.backgroundColor = [UIColor blackColor];
        WeightSwitchText.textColor = [UIColor whiteColor];
        
        self.tabBarController.tabBar.tintColor = [UIColor whiteColor];
        self.tabBarController.tabBar.barTintColor = [UIColor blackColor];
    }else{
        // Off
        self.view.backgroundColor = [UIColor whiteColor];
        settingsView.backgroundColor = [UIColor whiteColor];
        settingsView.backgroundView.backgroundColor = [UIColor whiteColor];
        HeartRateSwitchUI.backgroundColor = [UIColor whiteColor];
        HeartRateSwitchText.textColor = [UIColor blackColor];
        SleepSwitchUI.backgroundColor = [UIColor whiteColor];
        SleepSwitchText.textColor = [UIColor blackColor];
        StepsSwitchUI.backgroundColor = [UIColor whiteColor];
        StepsSwitchText.textColor = [UIColor blackColor];
        DistanceSwitchUI.backgroundColor = [UIColor whiteColor];
        DistanceSwitchText.textColor = [UIColor blackColor];
        FloorsSwitchUI.backgroundColor = [UIColor whiteColor];
        FloorsSwitchText.textColor = [UIColor blackColor];
        DarkModeSwitchUI.backgroundColor = [UIColor whiteColor];
        DarkModeSwitchText.textColor = [UIColor blackColor];
        SettingsLabel.textColor = [UIColor blackColor];
        NutrientsSwitchUI.backgroundColor = [UIColor whiteColor];
        NutrientsSwitchText.textColor = [UIColor blackColor];
        EnergySwitchUI.backgroundColor = [UIColor whiteColor];
        EnergySwitchText.textColor = [UIColor blackColor];
        WaterSwitchUI.backgroundColor = [UIColor whiteColor];
        WaterSwitchText.textColor = [UIColor blackColor];
        WeightSwitchUI.backgroundColor = [UIColor whiteColor];
        WeightSwitchText.textColor = [UIColor blackColor];
        self.tabBarController.tabBar.tintColor = [UIColor whiteColor];
        self.tabBarController.tabBar.barTintColor = [UIColor blackColor];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    // Heart Rate Switch - Change switch state from NSUserDefaults
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

    // Water Switch
    switchState = [[NSUserDefaults standardUserDefaults] boolForKey:@"waterSwitch"];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"waterSwitch"] == nil) {
        [WaterProfileSwitch setOn:YES];
    }else if (switchState == false) {
        [WaterProfileSwitch setOn:NO];
    }else{
        [WaterProfileSwitch setOn:YES];
    }

    // Energy Switch
    switchState = [[NSUserDefaults standardUserDefaults] boolForKey:@"activeEnergy"];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"activeEnergy"] == nil) {
        [EnergyProfileSwitch setOn:YES];
    }else if (switchState == false) {
        [EnergyProfileSwitch setOn:NO];
    }else{
        [EnergyProfileSwitch setOn:YES];
    }

    // Nutrients Switch
    switchState = [[NSUserDefaults standardUserDefaults] boolForKey:@"nutrientsSwitch"];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"nutrientsSwitch"] == nil) {
        [NutrientsProfileSwitch setOn:YES];
    }else if (switchState == false) {
        [NutrientsProfileSwitch setOn:NO];
    }else{
        [NutrientsProfileSwitch setOn:YES];
    }

    // Nutrients Switch
    switchState = [[NSUserDefaults standardUserDefaults] boolForKey:@"weightSwitch"];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"weightSwitch"] == nil) {
        [WeightProfileSwitch setOn:YES];
    }else if (switchState == false) {
        [WeightProfileSwitch setOn:NO];
    }else{
        [WeightProfileSwitch setOn:YES];
    }

    // Dark Mode Switch
    switchState = [[NSUserDefaults standardUserDefaults] boolForKey:@"DarkModeSwitch"];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"DarkModeSwitch"] == nil) {
        [DarkModeSwitch setOn:NO];
        self.view.backgroundColor = [UIColor whiteColor];
        settingsView.backgroundColor = [UIColor whiteColor];
        HeartRateSwitchUI.backgroundColor = [UIColor whiteColor];
        HeartRateSwitchText.textColor = [UIColor blackColor];
        SleepSwitchUI.backgroundColor = [UIColor whiteColor];
        SleepSwitchText.textColor = [UIColor blackColor];
        StepsSwitchUI.backgroundColor = [UIColor whiteColor];
        StepsSwitchText.textColor = [UIColor blackColor];
        DistanceSwitchUI.backgroundColor = [UIColor whiteColor];
        DistanceSwitchText.textColor = [UIColor blackColor];
        FloorsSwitchUI.backgroundColor = [UIColor whiteColor];
        FloorsSwitchText.textColor = [UIColor blackColor];
        DarkModeSwitchUI.backgroundColor = [UIColor whiteColor];
        DarkModeSwitchText.textColor = [UIColor blackColor];
        SettingsLabel.textColor = [UIColor blackColor];
        NutrientsSwitchUI.backgroundColor = [UIColor whiteColor];
        NutrientsSwitchText.textColor = [UIColor blackColor];
        EnergySwitchUI.backgroundColor = [UIColor whiteColor];
        EnergySwitchText.textColor = [UIColor blackColor];
        WaterSwitchUI.backgroundColor = [UIColor whiteColor];
        WaterSwitchText.textColor = [UIColor blackColor];
        WeightSwitchUI.backgroundColor = [UIColor whiteColor];
        WeightSwitchText.textColor = [UIColor blackColor];
        
        self.tabBarController.tabBar.tintColor = [UIColor whiteColor];
        self.tabBarController.tabBar.barTintColor = [UIColor blackColor];
    }else if (switchState == false) {
        [DarkModeSwitch setOn:NO];
        self.view.backgroundColor = [UIColor whiteColor];
        settingsView.backgroundColor = [UIColor whiteColor];
        settingsView.backgroundView.backgroundColor = [UIColor whiteColor];
        HeartRateSwitchUI.backgroundColor = [UIColor whiteColor];
        HeartRateSwitchText.textColor = [UIColor blackColor];
        SleepSwitchUI.backgroundColor = [UIColor whiteColor];
        SleepSwitchText.textColor = [UIColor blackColor];
        StepsSwitchUI.backgroundColor = [UIColor whiteColor];
        StepsSwitchText.textColor = [UIColor blackColor];
        DistanceSwitchUI.backgroundColor = [UIColor whiteColor];
        DistanceSwitchText.textColor = [UIColor blackColor];
        FloorsSwitchUI.backgroundColor = [UIColor whiteColor];
        FloorsSwitchText.textColor = [UIColor blackColor];
        DarkModeSwitchUI.backgroundColor = [UIColor whiteColor];
        DarkModeSwitchText.textColor = [UIColor blackColor];
        SettingsLabel.textColor = [UIColor blackColor];
        NutrientsSwitchUI.backgroundColor = [UIColor whiteColor];
        NutrientsSwitchText.textColor = [UIColor blackColor];
        self.tabBarController.tabBar.tintColor = [UIColor whiteColor];
        self.tabBarController.tabBar.barTintColor = [UIColor blackColor];
        
        EnergySwitchUI.backgroundColor = [UIColor whiteColor];
        EnergySwitchText.textColor = [UIColor blackColor];
        WaterSwitchUI.backgroundColor = [UIColor whiteColor];
        WaterSwitchText.textColor = [UIColor blackColor];
        WeightSwitchUI.backgroundColor = [UIColor whiteColor];
        WeightSwitchText.textColor = [UIColor blackColor];
    
    }else{
        [DarkModeSwitch setOn:YES];
        self.view.backgroundColor = [UIColor blackColor];
        settingsView.backgroundColor = [UIColor blackColor];
        settingsView.backgroundView.backgroundColor = [UIColor blackColor];
        HeartRateSwitchUI.backgroundColor = [UIColor blackColor];
        HeartRateSwitchText.textColor = [UIColor whiteColor];
        SleepSwitchUI.backgroundColor = [UIColor blackColor];
        SleepSwitchText.textColor = [UIColor whiteColor];
        StepsSwitchUI.backgroundColor = [UIColor blackColor];
        StepsSwitchText.textColor = [UIColor whiteColor];
        DistanceSwitchUI.backgroundColor = [UIColor blackColor];
        DistanceSwitchText.textColor = [UIColor whiteColor];
        FloorsSwitchUI.backgroundColor = [UIColor blackColor];
        FloorsSwitchText.textColor = [UIColor whiteColor];
        DarkModeSwitchUI.backgroundColor = [UIColor blackColor];
        DarkModeSwitchText.textColor = [UIColor whiteColor];
        SettingsLabel.textColor = [UIColor whiteColor];
        NutrientsSwitchUI.backgroundColor = [UIColor blackColor];
        NutrientsSwitchText.textColor = [UIColor whiteColor];

        WeightSwitchUI.backgroundColor = [UIColor blackColor];
        WeightSwitchText.textColor = [UIColor whiteColor];
        
        EnergySwitchUI.backgroundColor = [UIColor blackColor];
        EnergySwitchText.textColor = [UIColor whiteColor];
        WaterSwitchUI.backgroundColor = [UIColor blackColor];
        WaterSwitchText.textColor = [UIColor whiteColor];
        
        self.tabBarController.tabBar.tintColor = [UIColor whiteColor];
        self.tabBarController.tabBar.barTintColor = [UIColor blackColor];
    }
}

@end

