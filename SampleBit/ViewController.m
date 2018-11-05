//
//  ViewController.m
//  SampleBit
//
//  Created by Deepak on 1/18/17.
//  Copyright © 2017 InsanelyDeepak. All rights reserved.
//

#import "ViewController.h"
#import "FitbitExplorer.h"
@import HealthKit;

@interface ViewController ()

@end

@implementation ViewController
{
    FitbitAuthHandler *fitbitAuthHandler;
    __weak IBOutlet UITextView *resultView;
    __block BOOL heartRateSwitch;
    __block BOOL sleepSwitch;
    __block BOOL stepsSwitch;
    __block BOOL distanceSwitch;
    __block BOOL floorsSwitch;
    __block BOOL darkModeSwitch;
    __block HKHealthStore *hkstore;
    __block BOOL isRed;
    __block BOOL isDarkMode;
}

#define AS(A,B)    [(A) stringByAppendingString:(B)]

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    fitbitAuthHandler = [[FitbitAuthHandler alloc]init:self] ;
 
    resultView.layer.borderColor     = [UIColor lightGrayColor].CGColor;
    resultView.layer.borderWidth     = 0.0f;
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(notificationDidReceived) name:FitbitNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    // Heart Rate
    BOOL switchState = [[NSUserDefaults standardUserDefaults] boolForKey:@"heartSwitch"];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"heartSwitch"] == nil) {
        // No set
        heartRateSwitch = 1;
    }else  if (switchState == false) {
        // Turned off
        heartRateSwitch = 0;
    }else{
        // Turned on
        heartRateSwitch = 1;
    }
    
    // Sleep Rate
    switchState = [[NSUserDefaults standardUserDefaults] boolForKey:@"sleepSwitch"];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"sleepSwitch"] == nil) {
        // No set
        sleepSwitch = 1;
    }else  if (switchState == false) {
        // Turned off
        sleepSwitch = 0;
    }else{
        // Turned on
        sleepSwitch = 1;
    }
    
    // Step Rate
    switchState = [[NSUserDefaults standardUserDefaults] boolForKey:@"stepSwitch"];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"stepSwitch"] == nil) {
        // No set
        stepsSwitch = 1;
    }else  if (switchState == false) {
        // Turned off
        stepsSwitch = 0;
    }else{
        // Turned on
        stepsSwitch = 1;
    }

    // Distance Rate
    switchState = [[NSUserDefaults standardUserDefaults] boolForKey:@"distanceSwitch"];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"distanceSwitch"] == nil) {
        // No set
        distanceSwitch = 1;
    }else  if (switchState == false) {
        // Turned off
        distanceSwitch = 0;
    }else{
        // Turned on
        distanceSwitch = 1;
    }

    // Floor Rate
    switchState = [[NSUserDefaults standardUserDefaults] boolForKey:@"floorSwitch"];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"floorSwitch"] == nil) {
        // No set
        floorsSwitch = 1;
    }else  if (switchState == false) {
        // Turned off
        floorsSwitch = 0;
    }else{
        // Turned on
        floorsSwitch = 1;
    }

    // Dark Mode Switch
    switchState = [[NSUserDefaults standardUserDefaults] boolForKey:@"DarkModeSwitch"];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"DarkModeSwitch"] == nil) {
        // No set
        darkModeSwitch = 0;
        isDarkMode = 0;
        self.view.backgroundColor = [UIColor whiteColor];
        resultView.backgroundColor = [UIColor whiteColor];
        if(isRed == 0){
            resultView.textColor = [UIColor blackColor];
        }
        self.tabBarController.tabBar.tintColor = [UIColor whiteColor];
        self.tabBarController.tabBar.barTintColor = [UIColor blackColor];
        
    }else  if (switchState == false) {
        // Turned off
        darkModeSwitch = 0;
        isDarkMode = 0;
        self.view.backgroundColor = [UIColor whiteColor];
        resultView.backgroundColor = [UIColor whiteColor];
        if(isRed == 0){
            resultView.textColor = [UIColor blackColor];
        }
        self.tabBarController.tabBar.tintColor = [UIColor whiteColor];
        self.tabBarController.tabBar.barTintColor = [UIColor blackColor];
    }else{
        // Turned on
        self.view.backgroundColor = [UIColor blackColor];
        resultView.backgroundColor = [UIColor blackColor];
        if(isRed == 0){
            resultView.textColor = [UIColor whiteColor];
        }
        darkModeSwitch = 1;
        isDarkMode = 1;
        self.tabBarController.tabBar.tintColor = [UIColor whiteColor];
        self.tabBarController.tabBar.barTintColor = [UIColor blackColor];
    }
}

//Processing methods for different activity types
- (void)ProcessHeartRate{
    NSLog(@"test123");
}

// Generate URLS for dispatch group
-(NSMutableArray *)generateURLS{
    // url, entity name
    NSMutableArray *array = [[NSMutableArray alloc] init];

    /////////////////////////////////////////////// Get sleep data //////////////////////////////////////////////////
    NSString *startDate = [self calcDate:10];
    NSString *endDate = [self dateNow];
    NSString *entity;
    NSString *url;

    if(sleepSwitch){
        url = [NSString stringWithFormat:@"https://api.fitbit.com/1.2/user/-/sleep/date/%@/%@.json", startDate, endDate];
        entity = [NSString stringWithFormat:@"sleep"];
        [array addObject:[NSMutableArray arrayWithObjects:url,entity,nil]];
    }

    //////////////////////////////////////////// Get step data //////////////////////////////////////////////////////
    if(stepsSwitch){
        url = [NSString stringWithFormat:@"https://api.fitbit.com/1/user/-/activities/steps/date/%@/%@.json",startDate, endDate];
        entity = [NSString stringWithFormat:@"steps"];
        [array addObject:[NSMutableArray arrayWithObjects:url,entity,nil]];
    }

    ////////////////////////////////////////////// Get floor data //////////////////////////////////////////////////
    if(floorsSwitch){
        url = [NSString stringWithFormat:@"https://api.fitbit.com/1/user/-/activities/floors/date/%@/%@.json",startDate, endDate];
        entity = [NSString stringWithFormat:@"floors"];
        [array addObject:[NSMutableArray arrayWithObjects:url,entity,nil]];
    }

    ////////////////////////////////////////////// Get distance data ///////////////////////////////////////////////
    if(distanceSwitch){
        url = [NSString stringWithFormat:@"https://api.fitbit.com/1/user/-/activities/distance/date/%@/%@.json",startDate, endDate];
        entity = [NSString stringWithFormat:@"distance"];
        [array addObject:[NSMutableArray arrayWithObjects:url,entity,nil]];
    }

    ////////////////////////////////////////////// Get heart rate data /////////////////////////////////////////////
    
    if(heartRateSwitch){
        url = [NSString stringWithFormat:@"https://api.fitbit.com/1/user/-/activities/heart/date/%@/1d/1sec.json",endDate];
        entity = [NSString stringWithFormat:@"heart rate"];
        [array addObject:[NSMutableArray arrayWithObjects:url,entity,nil]];
    }

    // Return array
    return array;
}

-(void)notificationDidReceived{

    // Initial message, starting to sync
    resultView.text = @"Syncing data started...";

    // Loop over all urls
    [self getFitbitURL];
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



// Specific methods for processisng activity data types
// Heart Rate
- (void) ProcessHeartRate:( NSDictionary * ) jsonData
{
    // Access root container - resting heart rate
    NSArray * out = [jsonData objectForKey:@"activities-heart"];
    NSDictionary * block = out[0];
    NSDictionary * block2 = [block objectForKey:@"value"];
    NSString * restingHR = [block2 objectForKey:@"restingHeartRate"];
    
    //NSLog(@"%@", restingHR); //today
    
    //Interday time series with 1sec resolution for heart rate
    NSDictionary * out2 = [jsonData objectForKey:@"activities-heart-intraday"];
    NSArray *out3 = [out2 objectForKey:@"dataset"];
    
    for(NSDictionary * entry in out3){
        NSString * time = [entry objectForKey:@"time"]; //Time
        NSString * value = [entry objectForKey:@"value"]; //Heart Rate
        //NSLog(@"%@", time);
        //NSLog(@"%@", value);
    }
    
    //Add to Health Kit - TODO
}

// Floors walked
- (void) ProcessFloors:( NSDictionary * ) jsonData
{
    // Access root container
    NSArray * out = [jsonData objectForKey:@"activities-floors"];
    
    // Access day container
    for(int i=0; i< ([out count]); i++){
        NSDictionary *block = out[i];
        NSString * floors = [block objectForKey:@"value"]; //floor count
        NSString * date = [block objectForKey:@"dateTime"]; //date - YYYY-MM-DD
        
        //NSLog(@"%@", floors);
        //NSLog(@"%@", date);
    }
    
    //Add to Health Kit - TODO
}

// Steps
- (void) ProcessSteps:( NSDictionary * ) jsonData
{
    // Access root container
    NSArray * out = [jsonData objectForKey:@"activities-steps"];
    
    // Access day container
    for(int i=0; i< ([out count]); i++){
        NSDictionary *block = out[i];
        NSString * steps = [block objectForKey:@"value"]; //step count
        NSString * date = [block objectForKey:@"dateTime"]; //date - YYYY-MM-DD
        
        //NSLog(@"%@", steps);
        //NSLog(@"%@", date);
    }

    //Add to Health Kit - TODO
    
}

// Sleep
- (void) ProcessSleep:( NSDictionary * ) jsonData
{
    // Access root container
    NSArray * out = [jsonData objectForKey:@"sleep"];
    
    // Access day container
    for(int i=0; i< ([out count]); i++){
        NSDictionary *block = out[i];
        NSString * duration = [block objectForKey:@"duration"]; //duration in milliseconds
        NSString * date = [block objectForKey:@"dateOfSleep"]; //date - YYYY-MM-DD

        //NSLog(@"%@", duration);
        //NSLog(@"%@", date);
    }
    
    //Add to Health Kit - TODO
}

// Distance
- (void) ProcessDistance:( NSDictionary * ) jsonData
{
    // Access root container
    NSArray * out = [jsonData objectForKey:@"activities-distance"];
    
    // Access day container
    for(int i=0; i< ([out count]); i++){
        NSDictionary *block = out[i];
        NSString * distance = [block objectForKey:@"value"]; //distance in kilometers
        NSString * date = [block objectForKey:@"dateTime"]; //date - YYYY-MM-DD
        
        //NSLog(@"%@", distance);
        //NSLog(@"%@", date);
    }
    
    //Add to Health Kit - TODO
}

// Pass URL and return json from fitbit API
-(void)getFitbitURL{
    
    dispatch_group_t group = dispatch_group_create();
    
    NSMutableArray *URLS = [self generateURLS];
    for (NSMutableArray *entity in URLS){
        
        // Retrieve url and activity type
        NSString *url = entity[0];
        __block NSString *type = entity[1];
        
        // Enter group
        dispatch_group_enter(group);

        NSString *token = [FitbitAuthHandler getToken];
        FitbitAPIManager *manager = [FitbitAPIManager sharedManager];

        // Get URL
        [manager requestGET:url Token:token success:^(NSDictionary *responseObject) {
            
            // Update interface with message, passed from entity
            self->resultView.text = [[@"Importing " stringByAppendingString:type] stringByAppendingString:@" data..."];
            
            // Pass data to individual methods for processing
            NSString *methodName = AS(@"Process",[[type capitalizedString] stringByReplacingOccurrencesOfString:@" " withString:@""]);
            NSString *methodArgs = AS(methodName,@":");

            /*int d = sizeof(responseObject);
            printf("%d",d);
            
            for(id element in [responseObject description])
            {
                NSLog(@"%@", element);
                NSLog(@"=======================================");
                NSLog(@"Is of type: %@", [element class]);
                NSLog(@"Is of type NSString?: %@", ([[element class] isMemberOfClass:[NSString class]])? @"Yes" : @"No");
                NSLog(@"Is a kind of NSString: %@", ([[element classForCoder] isSubclassOfClass:[NSString class]])? @"Yes" : @"No");
            }*/
            
            @try{
                // Retrieve method for selected activity
                //self->resultView.text = [responseObject description];
                SEL doubleParamSelector = NSSelectorFromString(methodArgs);
                [self performSelector: doubleParamSelector withObject: responseObject];
            }
            @catch (NSException *exception){
                // Catch if failed
                NSLog(@"Error - Failed to find method");
            }

            // Leave group
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
    }

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        self->resultView.text = @"Sync Complete";
    });
}

- (IBAction)actionLogin:(UIButton *)sender {

    // Write types attributes
    NSArray *writeTypes = @[
                            [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
                            [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate],
                            [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed]
                            ];
    
    hkstore = [[HKHealthStore alloc] init];
    [hkstore requestAuthorizationToShareTypes:[NSSet setWithArray:writeTypes]
                                        readTypes:nil
                                        completion:^(BOOL success, NSError * _Nullable error) {

                                            printf("asdf");
                                            
        if(!success){
            printf("You didn't allow HealthKit to access these write data types.\nThe error was:\n \(error!.description).");
        }else{
            NSInteger errorCount = 0;

            // Steps Activity
            HKQuantityType *stepsType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
            errorCount += [self checktype:stepsType];

            // Heart Rate Activity
            HKQuantityType *heartRateType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
            errorCount += [self checktype:heartRateType];
            
            // Sleep Activity
            HKQuantityType *floorClimbedType = [HKCategoryType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed];
            errorCount += [self checktype:floorClimbedType];

            if(errorCount != 0){
                dispatch_async(dispatch_get_main_queue(), ^{
                    self->resultView.text = @"Please go to Apple Health app, and give access to all the types.";
                    self->resultView.textColor = [UIColor redColor];
                    self->isRed = 1;
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    self->resultView.text = @"";
                    self->isRed = 0;
                    
                    if(self->isDarkMode == 1){
                        self->resultView.textColor = [UIColor whiteColor];
                    }else{
                        self->resultView.textColor = [UIColor blackColor];
                    }
                });
                [self->fitbitAuthHandler login:self];
            }
        }
    }];
}

-(NSInteger)checktype:(HKQuantityType *)status{
    
    HKAuthorizationStatus activity = [hkstore authorizationStatusForType:status];
    
    NSInteger isActive;
    switch (activity) {
        case HKAuthorizationStatusSharingAuthorized:
            isActive = 0;
            break;
        case HKAuthorizationStatusSharingDenied:
            isActive = 1;
            break;
        case HKAuthorizationStatusNotDetermined:
            isActive = 1;
            break;
            
        default:
            break;
    }
    return isActive;
}

- (IBAction)actionRevokeAccess:(UIButton *)sender {
    NSString *token = [FitbitAuthHandler getToken];
    if (token != nil){
        [fitbitAuthHandler  revokeAccessToken:token];
        resultView.text = @"Please press login to authorize";
    }
}

@end
