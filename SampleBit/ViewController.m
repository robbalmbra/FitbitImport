//
//  ViewController.m
//  SampleBit
//
//  Created by Deepak on 1/18/17.
//  Copyright © 2017 InsanelyDeepak. All rights reserved.
//

#import "ViewController.h"
#import "FitbitExplorer.h"
@interface ViewController ()

@end

@implementation ViewController
{
    FitbitAuthHandler *fitbitAuthHandler;
    __weak IBOutlet UITextView *resultView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    fitbitAuthHandler = [[FitbitAuthHandler alloc]init:self] ;
    
    resultView.layer.borderColor     = [UIColor lightGrayColor].CGColor;
    resultView.layer.borderWidth     = 0.0f;
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(notificationDidReceived) name:FitbitNotification object:nil];

}

-(void)notificationDidReceived{
    //resultView.text = @"Authorization Successfull \nPlease press getProfile to fetch data of fitbit user profile";
    resultView.text = @"Syncing data started...";
}
-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(NSString *)calcDate:(int) noOfDays {
    // Get current datetime
    NSDate *currentDateTime = [NSDate date];
    
    // Instantiate a NSDateFormatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    // Set the dateFormatter format
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    // Get the date in dateFormatter format
    NSString *dateInString = [dateFormatter stringFromDate:currentDateTime];
    NSDate *selectedTime = [dateFormatter dateFromString:dateInString];
    
    // Minus noOfDays from current date and convert to NSSString
    NSDate *myTime = [selectedTime dateByAddingTimeInterval:-noOfDays*24*60*60];
    NSString *date = [dateFormatter stringFromDate:myTime];
    
    // Return
    return date;
}

-(NSString *)dateNow{
    // Get current datetime
    NSDate *currentDateTime = [NSDate date];
    
    // Instantiate a NSDateFormatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    // Set the dateFormatter format
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    // Get the date in NSString for both start and stop time
    NSString *date = [dateFormatter stringFromDate:currentDateTime];
    
    // Return
    return date;
}


- (IBAction)actionLogin:(UIButton *)sender {
    [fitbitAuthHandler login:self];
}

- (IBAction)actionGetProfile:(UIButton *)sender {
    NSString *token = [FitbitAuthHandler getToken];
    
    FitbitAPIManager *manager = [FitbitAPIManager sharedManager];
    //********** Pass your API here and get details in response **********
    NSString *urlString = [NSString stringWithFormat:@"https://api.fitbit.com/1/user/-/profile.json"] ;

    [manager requestGET:urlString Token:token success:^(NSDictionary *responseObject) {
        // ------ response -----
        resultView.text = [responseObject description];
        
    } failure:^(NSError *error) {
        NSData * errorData = (NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        NSDictionary *errorResponse =[NSJSONSerialization JSONObjectWithData:errorData options:NSJSONReadingAllowFragments error:nil];
        NSArray *errors = [errorResponse valueForKey:@"errors"];
        NSString *errorType = [[errors objectAtIndex:0] valueForKey:@"errorType"] ;
        if ([errorType isEqualToString:fInvalid_Client] || [errorType isEqualToString:fExpied_Token] || [errorType isEqualToString:fInvalid_Token]|| [errorType isEqualToString:fInvalid_Request]) {
            // To perform login if token is expired
            [fitbitAuthHandler login:self];
        }
    }];
}

- (IBAction)actionRevokeAccess:(UIButton *)sender {
    NSString *token = [FitbitAuthHandler getToken];
    if (token != nil){
        [fitbitAuthHandler  revokeAccessToken:token];
        resultView.text = @"Please press login to authorize";
    }
}

//get recent 10 days sleep data and insert into HealthKit
- (IBAction)actionGetSleep:(UIButton *)sender {
    NSString *token = [FitbitAuthHandler getToken];
    FitbitAPIManager *manager = [FitbitAPIManager sharedManager];
    
    // Day offset
    int noOfDays = 10;
    
    // Return now minus noOfDays to startDate and return now to enddate
    NSString *startDate = [self calcDate:noOfDays];
    NSString *endDate = [self dateNow];

    //create unique http address to API and execute
    NSString *urlString = [NSString stringWithFormat:@"https://api.fitbit.com/1.2/user/-/sleep/date/%@/%@.json", startDate, endDate] ;
    [manager requestGET:urlString Token:token success:^(NSDictionary *responseObject) {
        resultView.text = @"Importing sleep data...";
        //data = [responseObject description] //todo
        
        //test and parse data here
    } failure:^(NSError *error) {
        NSData * errorData = (NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        NSDictionary *errorResponse =[NSJSONSerialization JSONObjectWithData:errorData options:NSJSONReadingAllowFragments error:nil];
        NSArray *errors = [errorResponse valueForKey:@"errors"];
        NSString *errorType = [[errors objectAtIndex:0] valueForKey:@"errorType"] ;
        if ([errorType isEqualToString:fInvalid_Client] || [errorType isEqualToString:fExpied_Token] || [errorType isEqualToString:fInvalid_Token]|| [errorType isEqualToString:fInvalid_Request]) {
            // To perform login if token is expired
            [fitbitAuthHandler login:self];
        }
    }];
}

@end
