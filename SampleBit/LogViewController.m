//
//  LogViewController.m
//  SampleBit
//
//  Created by Robert Balmbra on 22/11/2018.
//  Copyright © 2018 insanelydeepak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogViewController.h"

@interface LogViewController ()

@end

@implementation LogViewController
{
    __weak IBOutlet UILabel *LogViewTitleTop;
    __weak IBOutlet UITextView *logView;
}

-(void)viewWillAppear:(BOOL)animated
{
    // Get log text
    logView.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"OutputLog"];
    
    // Dark mode if switched on
    BOOL switchState = [[NSUserDefaults standardUserDefaults] boolForKey:@"DarkModeSwitch"];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"DarkModeSwitch"] == nil ||  switchState == false) {
        // Off
        self.view.backgroundColor = [UIColor whiteColor];
        logView.backgroundColor = [UIColor whiteColor];
        logView.textColor = [UIColor blackColor];
        LogViewTitleTop.textColor = [UIColor blackColor];
    }else{
        logView.backgroundColor = [UIColor blackColor];
        self.view.backgroundColor = [UIColor blackColor];
        logView.textColor = [UIColor whiteColor];
        LogViewTitleTop.textColor = [UIColor whiteColor];
    }
}
@end
