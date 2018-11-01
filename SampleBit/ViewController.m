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
    NSString *JsonOutput;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    fitbitAuthHandler = [[FitbitAuthHandler alloc]init:self] ;
 
    JsonOutput = @"";
    resultView.layer.borderColor     = [UIColor lightGrayColor].CGColor;
    resultView.layer.borderWidth     = 0.0f;
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(notificationDidReceived) name:FitbitNotification object:nil];

}

// Generate URLS for dispatch group
-(NSMutableArray *)generateURL{
    // url, entity name
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    /////////////////////////////////////// Add sleep entity to array ///////////////////////////////////////////////////
    NSString *startDate = [self calcDate:10];
    NSString *endDate = [self dateNow];

    NSString *url = [NSString stringWithFormat:@"https://api.fitbit.com/1.2/user/-/sleep/date/%@/%@.json", startDate, endDate];
    NSString *entity = [NSString stringWithFormat:@"sleep"];
    [array addObject:[NSMutableArray arrayWithObjects:url,entity,nil]];

    ////////////////////////////////////////////// Get step data //////////////////////////////////////////////////////////
    url = [NSString stringWithFormat:@"https://api.fitbit.com/1/user/-/activities/steps/date/%@/%@.json",startDate, endDate];
    entity = [NSString stringWithFormat:@"steps"];
    [array addObject:[NSMutableArray arrayWithObjects:url,entity,nil]];
    
    //return array
    return array;
}

-(void)notificationDidReceived{

    // Initial message, starting to sync
    resultView.text = @"Syncing data started...";

    ////////////////////////////////////////////// Get sleep data //////////////////////////////////////////////////////////
    
    // Day offset
    int noOfDays = 10;
    
    // Get 10 days prior to date and date now
    NSString *startDate = [self calcDate:noOfDays];
    NSString *endDate = [self dateNow];
    
    // Create unique http address to API and execute
    NSString *urlString = [NSString stringWithFormat:@"https://api.fitbit.com/1.2/user/-/sleep/date/%@/%@.json", startDate, endDate] ;
    NSString *type = @"sleep";
    [self getFitbitURL: urlString withsecond: type];
}
-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// Get current date and minus noOfDays from it
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

// Get current date
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

// Pass URL and return json from fitbit API
-(void)getFitbitURL:(NSString *)URL withsecond:(NSString *)entity {
    
    __block NSString *responseJson = nil;
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    
    NSString *token = [FitbitAuthHandler getToken];
    FitbitAPIManager *manager = [FitbitAPIManager sharedManager];
    
    // Create unique http address to API and execute
    NSString *urlString = [NSString stringWithFormat:@"%@", URL] ;
    [manager requestGET:urlString Token:token success:^(NSDictionary *responseObject) {
        
        // Update interface with message, passed from entity
        self->resultView.text = [[@"Importing " stringByAppendingString:entity] stringByAppendingString:@" data..."];
        responseJson = [responseObject description];
        dispatch_group_leave(group);
        
    } failure:^(NSError *error) {
        NSData * errorData = (NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        NSDictionary *errorResponse =[NSJSONSerialization JSONObjectWithData:errorData options:NSJSONReadingAllowFragments error:nil];
        NSArray *errors = [errorResponse valueForKey:@"errors"];
        NSString *errorType = [[errors objectAtIndex:0] valueForKey:@"errorType"] ;
        if ([errorType isEqualToString:fInvalid_Client] || [errorType isEqualToString:fExpied_Token] || [errorType isEqualToString:fInvalid_Token]|| [errorType isEqualToString:fInvalid_Request]) {
            // To perform login if token is expired
            [self->fitbitAuthHandler login:self];
        }
        dispatch_group_leave(group);
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"All done");
    });
    NSLog(@"test");
}

- (IBAction)actionLogin:(UIButton *)sender {
    [fitbitAuthHandler login:self];
}

// Get user profile in json format
- (IBAction)actionGetProfile:(UIButton *)sender {
    NSString *token = [FitbitAuthHandler getToken];
    
    // Create unique http address to API and execute
    FitbitAPIManager *manager = [FitbitAPIManager sharedManager];
    NSString *urlString = [NSString stringWithFormat:@"https://api.fitbit.com/1/user/-/profile.json"] ;
    [manager requestGET:urlString Token:token success:^(NSDictionary *responseObject) {
        // Update interface with message
        self->resultView.text = @"Parsing Profile ...";
        
        // Date object containing json code
        //data = [responseObject description] //todo
        
    } failure:^(NSError *error) {
        NSData * errorData = (NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        NSDictionary *errorResponse =[NSJSONSerialization JSONObjectWithData:errorData options:NSJSONReadingAllowFragments error:nil];
        NSArray *errors = [errorResponse valueForKey:@"errors"];
        NSString *errorType = [[errors objectAtIndex:0] valueForKey:@"errorType"] ;
        if ([errorType isEqualToString:fInvalid_Client] || [errorType isEqualToString:fExpied_Token] || [errorType isEqualToString:fInvalid_Token]|| [errorType isEqualToString:fInvalid_Request]) {
            // To perform login if token is expired
            [self->fitbitAuthHandler login:self];
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

@end
