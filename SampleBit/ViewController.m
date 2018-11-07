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

// Generate URLS for dispatch group
-(NSMutableArray *)generateURLS{
    // url, entity name
    NSMutableArray *array = [[NSMutableArray alloc] init];

    /////////////////////////////////////////////// Get sleep data //////////////////////////////////////////////////
    NSString *startDate = [self calcDate:5];
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
    //Ten day span
    if(heartRateSwitch){
        for(int i=0; i<5; i++){
            NSString *dateNow = [self calcDate:i];
            url = [NSString stringWithFormat:@"https://api.fitbit.com/1/user/-/activities/heart/date/%@/1d/1min.json",dateNow];
            entity = [NSString stringWithFormat:@"heart rate"];
            [array addObject:[NSMutableArray arrayWithObjects:url,entity,nil]];
        }
        
        // Average walk HR
        url = [NSString stringWithFormat:@"https://api.fitbit.com/1/user/-/activities/list.json?afterDate=%@",startDate];
        entity = [NSString stringWithFormat:@"average walking heart rate"];
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

-(NSDate *)stitchDateTime:(NSString *) time {
    // Instantiate a NSDateFormatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    // Set format output
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    // Return date time in NSDate format
    NSDate *date = [dateFormatter dateFromString:time];
    
    // Return
    return date;
}

// Get Avergae Walk HR - TODO
- (void) ProcessAverageWalkingHeartRate:( NSDictionary * ) jsonData
{
    printf("%s",[[jsonData description] UTF8String]);
}

// Specific methods for processisng activity data types
// Heart Rate
- (void) ProcessHeartRate:( NSDictionary * ) jsonData
{
    // Access root container
    NSArray * out = [jsonData objectForKey:@"activities-heart"];
    NSDictionary * block = out[0];
    NSString * date = [block objectForKey:@"dateTime"];
    
    //printf("%s",[[jsonData description] UTF8String]);
    
    // Define type
    HKQuantityType *quantityType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    HKQuantityType *restingtype  = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierRestingHeartRate];
    
    // Access resting Heart Rate and intraday heart rate at 1sec resolution
    NSDictionary * block2 = [block objectForKey:@"value"];
    double restingHR = [[block2 objectForKey:@"restingHeartRate"] doubleValue];

    // Retrieve variables from json data
    HKUnit *bpmd = [HKUnit unitFromString:@"count/min"];
    NSDictionary * out2 = [jsonData objectForKey:@"activities-heart-intraday"];
    NSArray *out3 = [out2 objectForKey:@"dataset"];

    NSString * time2 = AS(date,@" 00:00:00");
    NSDate * dateTime1 = [self stitchDateTime:time2];

    NSString * time3 = AS(date,@" 23:59:59");
    NSDate * dateTime3 = [self stitchDateTime:time3];
    
    // If 0 dont insert
    if(restingHR != 0){
        HKQuantity *restingHRquality = [HKQuantity quantityWithUnit:bpmd doubleValue:restingHR];
        HKQuantitySample * hrRestingSample = [HKQuantitySample quantitySampleWithType:restingtype quantity:restingHRquality startDate:dateTime1 endDate:dateTime3];
    
        // Insert into healthkit and return response error or success
        [hkstore saveObject:hrRestingSample withCompletion:^(BOOL success, NSError *error){
            if(success) {
                //NSLog(@"success");
            }else {
                NSLog(@"error");
            }
        }];
    }
    
    NSMutableArray *bpmArray = [NSMutableArray array];
    
    // Iterate over intraday dataset
    for(NSDictionary * entry in out3){
        NSString * time = [entry objectForKey:@"time"];
        NSDate * dateTime = [self stitchDateTime:AS(AS(date,@" "),time)];
        double value = [[entry objectForKey:@"value"] doubleValue];

        // Defined unit and quantity
        HKUnit *bpm = [HKUnit unitFromString:@"count/min"];
        HKQuantity *quantity = [HKQuantity quantityWithUnit:bpm doubleValue:value];
        
        // Create sample
        HKQuantitySample * hrSample = [HKQuantitySample quantitySampleWithType:quantityType quantity:quantity startDate:dateTime endDate:dateTime];
        
        // Add sample to array
        [bpmArray addObject:hrSample];
    }

    // Add to healthkit
    [hkstore saveObjects:bpmArray withCompletion:^(BOOL success, NSError *error){
        if(success) {
            NSLog(@"success");
        }else {
            NSLog(@"%@", error);
        }
        
    }];
}

// Floors walked
- (void) ProcessFloors:( NSDictionary * ) jsonData
{
    // Access root container
    NSArray * out = [jsonData objectForKey:@"activities-floors"];
    
    // Define type
    HKQuantityType *floorsType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed];

    // Access day container
    for(int i=0; i< ([out count]); i++){
        NSDictionary *block = out[i];
        
        // Retrieve variables from json data
        double floors = [[block objectForKey:@"value"] doubleValue];
        NSDate * date = [self convertDate:[block objectForKey:@"dateTime"]];
        HKUnit *floorUnit = [HKUnit unitFromString:@"count"];
        
        //Defined quantity
        HKQuantity *quantity = [HKQuantity quantityWithUnit:floorUnit doubleValue:floors];
        
        NSDate *now = [NSDate date];
        NSNumber *nowEpochSeconds = [NSNumber numberWithInt:[now timeIntervalSince1970]];
        
        NSString *identifer = AS([block objectForKey:@"dateTime"],@"Floors");
        
        NSDictionary * metadata =
        @{HKMetadataKeySyncIdentifier: identifer,
          HKMetadataKeySyncVersion: nowEpochSeconds};

        // Create Sample with floors value
        HKQuantitySample * floorSample = [HKQuantitySample quantitySampleWithType:floorsType quantity:quantity startDate:date endDate:date metadata:metadata];
        
        // Insert into healthkit and return response error or success
        [hkstore saveObject:floorSample withCompletion:^(BOOL success, NSError *error){
            if(success) {
                //NSLog(@"success");
            }else {
                NSLog(@"%@", error);
            }
        }];
    }
}

// Steps
- (void) ProcessSteps:( NSDictionary * ) jsonData
{
    // Access root container
    NSArray * out = [jsonData objectForKey:@"activities-steps"];

    // Define type
    HKQuantityType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];

    // Define unit
    HKUnit *stepUnit = [HKUnit unitFromString:@"count"];
    
    // Access day container
    for(int i=0; i< ([out count]); i++){
        NSDictionary *block = out[i];

        // Retrieve variables from json data
        double steps = [[block objectForKey:@"value"] doubleValue];
        NSDate * date = [self convertDate:[block objectForKey:@"dateTime"]];

        // Define quantity
        HKQuantity *quantity = [HKQuantity quantityWithUnit:stepUnit doubleValue:steps];

        NSDate *now = [NSDate date];
        NSNumber *nowEpochSeconds = [NSNumber numberWithInt:[now timeIntervalSince1970]];

        NSString *identifer = AS([block objectForKey:@"dateTime"],@"Steps");
        
        NSDictionary * metadata =
        @{HKMetadataKeySyncIdentifier: identifer,
          HKMetadataKeySyncVersion: nowEpochSeconds};

        // Create Sample with floors value
        HKQuantitySample * stepSample = [HKQuantitySample quantitySampleWithType:stepType quantity:quantity startDate:date endDate:date metadata:metadata];

        // Insert into healthkit and return response error or success
        [hkstore saveObject:stepSample withCompletion:^(BOOL success, NSError *error){
            if(success) {
                //NSLog(@"success");
            }else {
                NSLog(@"%@", error);
            }
        }];
    }
}

- (NSDate *)convertDate:(NSString *) Simpledate{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    [dateFormat setFormatterBehavior:NSDateFormatterBehaviorDefault];
    NSDate *date = [dateFormat dateFromString:Simpledate];
    [dateFormat setDateFormat:@"yyyy/MM/dd"];
    NSString *finalStr = [dateFormat stringFromDate:date];
    NSDate *dateFromString = [dateFormat dateFromString:finalStr];
    return dateFromString;
}
                           
- (NSDate *)convertDateTime:(NSString *) dateTime{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
    [dateFormat setFormatterBehavior:NSDateFormatterBehaviorDefault];
    NSDate *date = [dateFormat dateFromString:dateTime];
    [dateFormat setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSString *finalStr = [dateFormat stringFromDate:date];
    NSDate *dateFromString = [dateFormat dateFromString:finalStr];
    return dateFromString;
}

// Sleep
- (void) ProcessSleep:( NSDictionary * ) jsonData
{
    NSDate *startDate;
    NSDate *endDate;
    
    // Access root container
    NSArray * out = [jsonData objectForKey:@"sleep"];

    // Declare type
    HKCategoryType *sleepType = [HKCategoryType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
    
    // Access day container
    for(int i=0; i< ([out count]); i++){
        NSDictionary *block = out[i];
        NSString * start = [block objectForKey:@"startTime"];
        NSTimeInterval secondsAsleep = [[block objectForKey:@"minutesAsleep"] intValue]*60;
        NSTimeInterval minutesAwake = [[block objectForKey:@"minutesAwake"] intValue]*60;
        
        // Get compliant dates for function and calculate end time/date
        startDate = [self convertDateTime:start];
        endDate = [[startDate dateByAddingTimeInterval:secondsAsleep] dateByAddingTimeInterval:minutesAwake];

        NSDate *now = [NSDate date];
        NSNumber *nowEpochSeconds = [NSNumber numberWithInt:[now timeIntervalSince1970]];
        
        NSString *identifer = AS(start,@"Asleep");
        
        NSDictionary * metadata =
        @{HKMetadataKeySyncIdentifier: identifer,
          HKMetadataKeySyncVersion: nowEpochSeconds};
        
        // Get start and end of sleep
        HKCategorySample * sleepSample = [HKCategorySample categorySampleWithType:sleepType value:HKCategoryValueSleepAnalysisInBed startDate:startDate endDate:endDate metadata:metadata];

        // Insert into healthkit and return response error or success
        [hkstore saveObject:sleepSample withCompletion:^(BOOL success, NSError *error){
            if(success) {
                //NSLog(@"success");
            }else {
                NSLog(@"%@", error);
            }
        }];
    }
}

// Distance
- (void) ProcessDistance:( NSDictionary * ) jsonData
{
    // Access root container
    NSArray * out = [jsonData objectForKey:@"activities-distance"];
    
    // Access day container
    for(int i=0; i< ([out count]); i++){
        //NSDictionary *block = out[i];
        //NSString * distance = [block objectForKey:@"value"]; //distance in kilometers
        //NSString * date = [block objectForKey:@"dateTime"]; //date - YYYY-MM-DD
        
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

            @try{
                // Retrieve method for selected activity
                //self->resultView.text = [responseObject description];
                SEL doubleParamSelector = NSSelectorFromString(methodArgs);
                [self performSelector: doubleParamSelector withObject: responseObject];
            }
            @catch (NSException *exception){
                // Catch if failed
                NSLog(@"Error - Failed to find method `%@`",methodName);
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
                            [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierRestingHeartRate],
                            [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryWater],
                            [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed],
                            [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis]
                            ];
    
    hkstore = [[HKHealthStore alloc] init];
    [hkstore requestAuthorizationToShareTypes:[NSSet setWithArray:writeTypes]
                                        readTypes:nil
                                        completion:^(BOOL success, NSError * _Nullable error) {

        if(!success){
            //nothing
        }else{
            NSInteger errorCount = 0;

            if(self->stepsSwitch){
                // Steps Activity
                HKObjectType *stepsType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
                HKAuthorizationStatus stepTypesStatus = [self->hkstore authorizationStatusForType:stepsType];
                errorCount += [self checktype:stepTypesStatus];
            }

            if(self->heartRateSwitch){
                // Heart Rate Activity
                HKObjectType *heartRateType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
                HKAuthorizationStatus heartRateTypeStatus = [self->hkstore authorizationStatusForType:heartRateType];
                errorCount += [self checktype:heartRateTypeStatus];

                HKObjectType *heartRateRestingType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierRestingHeartRate];
                HKAuthorizationStatus heartRateRestingTypeStatus = [self->hkstore authorizationStatusForType:heartRateRestingType];
                errorCount += [self checktype:heartRateRestingTypeStatus];
            }

            if(self->floorsSwitch){
                // Floor Climbed Activity
                HKObjectType *floorClimbedType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed];
                HKAuthorizationStatus floorClimbedTypeStatus = [self->hkstore authorizationStatusForType:floorClimbedType];
                errorCount += [self checktype:floorClimbedTypeStatus];
            }

            // Sleep
            if(self->sleepSwitch){
                HKObjectType *sleep = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
                HKAuthorizationStatus sleepStatus = [self->hkstore authorizationStatusForType:sleep];
                errorCount += [self checktype:sleepStatus];
            }

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

-(NSInteger)checktype:(HKAuthorizationStatus)activity{
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
