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
        __weak IBOutlet UITextView *logView;
}

-(void)viewWillAppear:(BOOL)animated
{
    logView.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"OutputLog"];
}
@end
