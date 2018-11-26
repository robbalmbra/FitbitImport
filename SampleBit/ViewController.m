//
//  ViewController.m
//  SampleBit
//
//  Created by Deepak on 1/18/17.
//  Copyright © 2017 InsanelyDeepak. All rights reserved.
//

#import "ViewController.h"
#import "FitbitExplorer.h"
@import CoreLocation;
@import HealthKit;

@interface ViewController ()

@end

@implementation ViewController
{
    FitbitAuthHandler *fitbitAuthHandler;
    __weak IBOutlet UITextView *resultView;
    
    __weak IBOutlet UIProgressView * ProgressBar;
    
    __block BOOL heartRateSwitch;
    __block BOOL sleepSwitch;
    __block BOOL nutrients;
    __block BOOL stepsSwitch;
    __block BOOL distanceSwitch;
    __block BOOL floorsSwitch;
    __block BOOL waterSwitch;
    __block BOOL activeEnergy;
    __block BOOL darkModeSwitch;
    __block BOOL nutrientsSwitch;
    __block BOOL weightSwitch;
    __block NSString *userid;
    __block HKHealthStore *hkstore;
    __block NSString *tcxLink;
    __block BOOL isRed;
    __block BOOL isDarkMode;
    __block BOOL apiNoRequests;
    __block BOOL backgroundMode;
    __block BOOL backgroundModeOn;
    __block NSInteger nearestHour;
    __block NSString * distance;
    __block NSMutableArray * workoutArray;
    __block NSMutableArray * sleepArray;
    __block NSInteger running;
    __block int workoutComplete;
    __block NSTimer * timer;
    __block double count;
    __block double progress;
    __block BOOL launchedFitAuth;
    __block NSMutableArray *activityLogArray;
    __block NSMutableArray *URLs;
    __block int typeCount;
    __block int typeCountCheck;
    __block NSMutableArray *urlArray;
    __block NSMutableArray *skipArray;
    __block BOOL foundWorkout;
}

#define AS(A,B)    [(A) stringByAppendingString:(B)]

typedef void (^ButtonCompletionBlock)(NSDictionary * jsonData, NSError * error);
typedef void (^QueryCompletetionBlock)(NSInteger count, NSError * error);
typedef void (^QueryCompletionBlock)(NSInteger count, NSMutableArray * data, NSError * error);

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    fitbitAuthHandler = [[FitbitAuthHandler alloc]init:self] ;
 
    resultView.layer.borderColor     = [UIColor lightGrayColor].CGColor;
    resultView.layer.borderWidth     = 0.0f;
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(notificationDidReceived) name:FitbitNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    activityLogArray = [[NSMutableArray alloc] init];
    
    self->nearestHour = -1;
    self->launchedFitAuth = 0;
    
    //Define array if ns array is not set
    self->workoutArray = [NSMutableArray new];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    //retrieve background value
    BOOL switchState = [[NSUserDefaults standardUserDefaults] boolForKey:@"backgroundSwitch"];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"backgroundSwitch"] == nil || (switchState == false)) {
        // Turned off
        self->backgroundMode = 0;
        self->backgroundModeOn = 0;
    }else{
        if(self->running == 0){
            
            //Add code here for multiple requests in the background - TODO
            
            // Turned on
            self->backgroundMode = 1;
            self->backgroundModeOn = 1;
            self->running = 1;
            NSLog(@"Running background mode");
            [self getFitbitUserID];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    // Water Switch
    BOOL switchState = [[NSUserDefaults standardUserDefaults] boolForKey:@"waterSwitch"];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"waterSwitch"] == nil) {
        // No set
        waterSwitch = 1;
    }else  if (switchState == false) {
        // Turned off
        waterSwitch = 0;
    }else{
        // Turned on
        waterSwitch = 1;
    }

    // Energy Switch
    switchState = [[NSUserDefaults standardUserDefaults] boolForKey:@"activeEnergy"];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"activeEnergy"] == nil) {
        // No set
        activeEnergy = 1;
    }else  if (switchState == false) {
        // Turned off
        activeEnergy = 0;
    }else{
        // Turned on
        activeEnergy = 1;
    }
    
    // Nutrients Switch
    switchState = [[NSUserDefaults standardUserDefaults] boolForKey:@"nutrientsSwitch"];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"nutrientsSwitch"] == nil) {
        // No set
        nutrients = 1;
    }else  if (switchState == false) {
        // Turned off
        nutrients = 0;
    }else{
        // Turned on
        nutrients = 1;
    }
    
    // Heart Rate
    switchState = [[NSUserDefaults standardUserDefaults] boolForKey:@"heartSwitch"];
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
    
    // Weight
    switchState = [[NSUserDefaults standardUserDefaults] boolForKey:@"weightSwitch"];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"weightSwitch"] == nil) {
        // No set
        weightSwitch = 1;
    }else  if (switchState == false) {
        // Turned off
        weightSwitch = 0;
    }else{
        // Turned on
        weightSwitch = 1;
    }

    // Weight
    switchState = [[NSUserDefaults standardUserDefaults] boolForKey:@"backgroundSwitch"];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"backgroundSwitch"] == nil) {
        // No set
        backgroundMode = 0;
    }else  if (switchState == false) {
        // Turned off
        backgroundMode = 0;
    }else{
        // Turned on
        backgroundMode = 1;
    }
    
    // Dark Mode Switch
    switchState = [[NSUserDefaults standardUserDefaults] boolForKey:@"DarkModeSwitch"];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"DarkModeSwitch"] == nil) {
        // No set
        darkModeSwitch = 0;
        isDarkMode = 0;
        self.view.backgroundColor = [UIColor whiteColor];
        resultView.backgroundColor = [UIColor whiteColor];
        if(apiNoRequests == 0){
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
        if(apiNoRequests == 0){
            resultView.textColor = [UIColor blackColor];
        }
        self.tabBarController.tabBar.tintColor = [UIColor whiteColor];
        self.tabBarController.tabBar.barTintColor = [UIColor blackColor];
    }else{
        // Turned on
        self.view.backgroundColor = [UIColor blackColor];
        resultView.backgroundColor = [UIColor blackColor];
        if(apiNoRequests == 0){
            resultView.textColor = [UIColor whiteColor];
        }
        darkModeSwitch = 1;
        isDarkMode = 1;
        self.tabBarController.tabBar.tintColor = [UIColor whiteColor];
        self.tabBarController.tabBar.barTintColor = [UIColor blackColor];
    }

    if(self->apiNoRequests == 1){
        self->resultView.textColor = [UIColor redColor];
    }
}

-(void)logText:(NSString *) text {
    
    // Retrieve string
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString * logContent = [[NSUserDefaults standardUserDefaults] objectForKey:@"OutputLog"];

    // Check if logContent is nil
    if(logContent == nil){
        logContent = @"";
    }
    
    // Add time prefix
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm:ss"];
    NSString * date = AS(AS(@"[",[formatter stringFromDate:[NSDate date]]),@"] ");
    
    // Print message to console
    NSLog(@"%@", text);
    
    // Append to string
    NSString * outputContent = AS(logContent,AS(date,AS(text,@"\n")));

    // Save
    [defaults setValue:outputContent forKey:@"OutputLog"];
    [defaults synchronize];
}

-(void)countPoints:(HKSampleType *) type unit:(HKUnit *) unit dateArray:(NSMutableArray*) dateArray completion:(QueryCompletionBlock)completionBlock{
    
    // Date/time
    NSDate *startDate = [self stitchDateTime:AS(dateArray[0][2],@" 00:00:00")];
    NSDate *endDate = [self stitchDateTime:AS(dateArray[0][2],@" 23:59:59")];
    
    // Specifiy search parameters
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    
    // Search query
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:type predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:nil resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        
        if(error){
            // Return
            completionBlock(0,dateArray,error);
        }else{
            
            double output = 0;
            for(HKQuantitySample * sample in results){
                output += [sample.quantity doubleValueForUnit:unit];
            }
            
            // Return
            completionBlock(output,dateArray,nil);
        }
    }];

    // Run query
    [self->hkstore executeQuery:query];
}

-(void)isComplete:(NSTimer *)theTimer{
    if(self->typeCountCheck == self->typeCount){
        
        // Calculate progress bar
        self->count = 1.0f/([self->urlArray count] + 1);
        
        // Run get fitbit data
        [self getFitbitURL];

        [theTimer invalidate];
    }
}

// Generate URLS for dispatch group
-(void)generateURLS{

    self->urlArray = [[NSMutableArray alloc] init];
    self->skipArray = [[NSMutableArray alloc] init];

    NSString *startDate = [self calcDate:3];
    NSString *endDate = [self dateNow];
    __block NSString *entity;
    __block NSString *url;

    // Set counts to 0, used to check in timer
    self->typeCountCheck = 0;
    self->typeCount = 0;
    
    // How many days to process (today - Days);
    int Days = 3;

    ////////////////////////////////////////////////// Steps ///////////////////////////////////////////////////////
    
    if(self->stepsSwitch){
        self->typeCountCheck += 1;
        NSMutableArray *array1 = [[NSMutableArray alloc] init];
        for(int i=0; i<Days; i++){
            NSString *dateNow = [self calcDate:i];
            url = [NSString stringWithFormat:@"https://api.fitbit.com/1/user/-/activities/steps/date/%@/1d/15min.json",dateNow];
            entity = [NSString stringWithFormat:@"steps"];
            [array1 addObject:[NSMutableArray arrayWithObjects:url,entity,dateNow,nil]];
        }
        
        // Check healthkit for duplicate data
        HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
        HKUnit *unit = [HKUnit countUnit];
        
        // Query and return
        [self countPoints:sampleType unit:unit dateArray:array1 completion:^(NSInteger count, NSMutableArray * dataArray, NSError *error) {
            
            if(count != 0){
                [self->skipArray addObject:@"steps"];
                [self->skipArray addObject:@"steps"];
                [dataArray removeObjectAtIndex:2];
                [dataArray removeObjectAtIndex:1];
            }

            // Insert into array
            for(int i=0; i<[dataArray count]; i++){
                [self->urlArray addObject:dataArray[i]];
            }
            
            // Increase count
            self->typeCount +=1;
        }];
    }
    
    ////////////////////////////////////////////// Get floor data //////////////////////////////////////////////////
    if(self->floorsSwitch){
        self->typeCountCheck += 1;
        NSMutableArray *array2 = [[NSMutableArray alloc] init];
        for(int i=0; i<Days; i++){
            NSString *dateNow = [self calcDate:i];
            url = [NSString stringWithFormat:@"https://api.fitbit.com/1/user/-/activities/floors/date/%@/1d/15min.json",dateNow];
            entity = [NSString stringWithFormat:@"floors"];
            [array2 addObject:[NSMutableArray arrayWithObjects:url,entity,dateNow,nil]];
        }
        
        // Check healthkit for duplicate data
        HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed];
        HKUnit *unit = [HKUnit countUnit];
        
        // Query and return
        [self countPoints:sampleType unit:unit dateArray:array2 completion:^(NSInteger count, NSMutableArray * dataArray, NSError *error) {
            if(count != 0){
                [self->skipArray addObject:@"floors"];
                [self->skipArray addObject:@"floors"];
                [dataArray removeObjectAtIndex:2];
                [dataArray removeObjectAtIndex:1];
            }
            
            // Insert into array
            for(int i=0; i<[dataArray count]; i++){
                [self->urlArray addObject:dataArray[i]];
            }
            
            // Increase count
            self->typeCount +=1;
        }];
    }

    ////////////////////////////////////////////////// Energy /////////////////////////////////////////////////////
    if(self->activeEnergy){
        self->typeCountCheck += 1;
        NSMutableArray *array3 = [[NSMutableArray alloc] init];
        for(int i=0; i<Days; i++){
            NSString *dateNow = [self calcDate:i];
            url = [NSString stringWithFormat:@"https://api.fitbit.com/1/user/-/activities/calories/date/%@/1d/15min.json",dateNow];
            entity = [NSString stringWithFormat:@"calories"];
            [array3 addObject:[NSMutableArray arrayWithObjects:url,entity,dateNow,nil]];
        }
        
        // Check healthkit for duplicate data
        HKSampleType *sampleType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
        HKUnit *unit = [HKUnit unitFromString:@"cal"];
        
        // Query and return
        [self countPoints:sampleType unit:unit dateArray:array3 completion:^(NSInteger count, NSMutableArray * dataArray, NSError *error) {
            if(count != 0){
                [self->skipArray addObject:@"calories"];
                [self->skipArray addObject:@"calories"];
                [dataArray removeObjectAtIndex:2];
                [dataArray removeObjectAtIndex:1];
            }
            
            // Insert into array
            for(int i=0; i<[dataArray count]; i++){
                [self->urlArray addObject:dataArray[i]];
            }
            
            // Increase count
            self->typeCount +=1;
        }];
    }
    
    ////////////////////////////////////////////// Weight/BMI /////////////////////////////////////////////////////
    if(self->weightSwitch){
        self->typeCountCheck += 1;
        NSMutableArray *array4 = [[NSMutableArray alloc] init];
        for(int i=0; i<Days; i++){
            NSString *dateNow = [self calcDate:i];
            url = [NSString stringWithFormat:@"https://api.fitbit.com/1/user/-/body/weight/date/%@/%@.json",startDate, endDate];
            entity = [NSString stringWithFormat:@"weight"];
            [array4 addObject:[NSMutableArray arrayWithObjects:url,entity,dateNow,nil]];
        }
        
        // Check healthkit for duplicate data
        HKSampleType *sampleType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
        HKUnit *unit = [HKUnit unitFromString:@"kg"];
        
        // Query and return
        [self countPoints:sampleType unit:unit dateArray:array4 completion:^(NSInteger count, NSMutableArray * dataArray, NSError *error) {
            if(count != 0){
                [self->skipArray addObject:@"weight"];
                [self->skipArray addObject:@"weight"];
                [dataArray removeObjectAtIndex:2];
                [dataArray removeObjectAtIndex:1];
            }
            
            // Insert into array
            for(int i=0; i<[dataArray count]; i++){
                [self->urlArray addObject:dataArray[i]];
            }
            
            // Increase count
            self->typeCount +=1;
        }];
        
        self->typeCountCheck += 1;
        NSMutableArray *array5 = [[NSMutableArray alloc] init];
        for(int i=0; i<Days; i++){
            NSString *dateNow = [self calcDate:i];
            url = [NSString stringWithFormat:@"https://api.fitbit.com/1/user/-/body/bmi/date/%@/%@.json",startDate, endDate];
            entity = [NSString stringWithFormat:@"bmi"];
            [array5 addObject:[NSMutableArray arrayWithObjects:url,entity,dateNow,nil]];
        }
        
        // Check healthkit for duplicate data
        HKSampleType *sampleType2 = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMassIndex];
        HKUnit *unit2 = [HKUnit countUnit];
        
        // Query and return
        [self countPoints:sampleType2 unit:unit2 dateArray:array5 completion:^(NSInteger count, NSMutableArray * dataArray, NSError *error) {
            if(count != 0){
                [self->skipArray addObject:@"bmi"];
                [self->skipArray addObject:@"bmi"];
                [dataArray removeObjectAtIndex:2];
                [dataArray removeObjectAtIndex:1];
            }
            
            // Insert into array
            for(int i=0; i<[dataArray count]; i++){
                [self->urlArray addObject:dataArray[i]];
            }
            
            // Increase count
            self->typeCount +=1;
        }];
    }

    // Convert below to async functions - TODO

    ////////////////////////////////////////////// Get workout data ////////////////////////////////////////////////
    if(self->distanceSwitch){
        url = [NSString stringWithFormat:@"https://api.fitbit.com/1/user/-/activities/list.json?beforeDate=%@T23:59:59&sort=desc&limit=20&offset=0",endDate];
        entity = [NSString stringWithFormat:@"workout"];
        [self->urlArray addObject:[NSMutableArray arrayWithObjects:url,entity,nil]];
    }
    
    ///////////////////////////////////////////////// Food properties /////////////////////////////////////////////
    if(self->nutrients){
        for(int i=0; i<Days; i++){
            NSString *dateNow = [self calcDate:i];
            
            url = [NSString stringWithFormat:@"https://api.fitbit.com/1/user/-/foods/log/date/%@.json",dateNow];
            entity = [NSString stringWithFormat:@"nutrients"];
            [self->urlArray addObject:[NSMutableArray arrayWithObjects:url,entity,nil]];
        }
    }
    
    ////////////////////////////////////////////// Get heart rate data /////////////////////////////////////////////
    if(self->heartRateSwitch){
        for(int i=0; i<Days; i++){
            NSString *dateNow = [self calcDate:i];
     
            url = [NSString stringWithFormat:@"https://api.fitbit.com/1/user/-/activities/heart/date/%@/1d/1min.json",dateNow];
            entity = [NSString stringWithFormat:@"heart rate"];
            [self->urlArray addObject:[NSMutableArray arrayWithObjects:url,entity,nil]];
        }
     }

    //////////////////////////////////////////////// Water Consumed ///////////////////////////////////////////////
    if(self->waterSwitch){
        url = [NSString stringWithFormat:@"https://api.fitbit.com/1/user/-/foods/log/water/date/%@/%@.json",startDate, endDate];
        entity = [NSString stringWithFormat:@"water"];
        [self->urlArray addObject:[NSMutableArray arrayWithObjects:url,entity,nil]];
    }

    ///////////////////////////////////////////////////// Sleep //////////////////////////////////////////////////////
    if(self->sleepSwitch){
        url = [NSString stringWithFormat:@"https://api.fitbit.com/1.2/user/-/sleep/date/%@/%@.json", startDate, endDate];
        entity = [NSString stringWithFormat:@"sleep"];
        [self->urlArray addObject:[NSMutableArray arrayWithObjects:url,entity,nil]];
    }
    
    // Timer to complete async methods
    self->timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(isComplete:) userInfo:nil repeats:YES];
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    [runloop addTimer:self->timer forMode:NSDefaultRunLoopMode];
}

-(void)notificationDidReceived{
    // Initial message, starting to sync
    if(self->apiNoRequests == 0){
        self->running = 1;

        dispatch_async(dispatch_get_main_queue(),^{
            self->resultView.text = @"Syncing data started...";
        });

        // Loop over all urls
        [self getFitbitUserID];
    }
}
-(void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// Get current date and time in full notation
-(NSString *)getDate{
    // Get current datetime
    NSDate *currentDateTime = [NSDate date];
    
    // Instantiate a NSDateFormatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    // Set the dateFormatter format
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    
    NSString *date = [dateFormatter stringFromDate:currentDateTime];
    return date;
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

-(NSDate*)str2date:(NSString*)dateStr{
    if ([dateStr isKindOfClass:[NSDate class]]) {
        return (NSDate*)dateStr;
    }
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:dateStr];
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

// Return device information
- (HKDevice *) ReturnDeviceInfo:(NSString *) model
{
    if(model == nil){
        model = @"-";
    }
    
    HKDevice *device = [[HKDevice alloc] initWithName:@"Fitbit" manufacturer:@"Fitbit" model:model hardwareVersion:@"-" firmwareVersion:@"2.1" softwareVersion:@"1.1" localIdentifier:@"1.1" UDIDeviceIdentifier:@"a5b2e8f9d2a983e3a9d3e21"];
    
    return device;
}

// Return metadata to avoid duplication of data
- (NSMutableDictionary *) ReturnMetadata:(NSString *) type date:(NSString *) date extra:(NSMutableDictionary *)extra
{
    NSDate *now = [NSDate date];
    NSNumber *nowEpochSeconds = [NSNumber numberWithInt:[now timeIntervalSince1970]];
    
    NSString *identifer = AS(date,type);
    NSMutableDictionary *meta = [[NSMutableDictionary alloc] init];
    [meta setObject:identifer forKey:HKMetadataKeySyncIdentifier];
    [meta setObject:nowEpochSeconds forKey:HKMetadataKeySyncVersion];
    [meta setObject:@2 forKey:HKMetadataKeyHeartRateSensorLocation];

    // add extra key/values from extra to metadata
    if(extra != nil){
        for(NSString * key in extra){
           [meta setObject:extra[key] forKey:key];
        }
    }
    return meta;
}

- (void) ProcessTest: (NSDictionary *) jsonData
{
    //printf("%s",[[jsonData description] UTF8String]);
}

- (void) ProcessBmi:( NSDictionary *) jsonData
{
    NSString * DateStitch;
    NSDate * sampleDate;

    // Define sample array
    NSMutableArray *sampleArray = [NSMutableArray array];

    // Healthkit unit and type declarations
    HKUnit *unit = [HKUnit unitFromString:@"count"];
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMassIndex];
    HKQuantity *weightQuantity;
    HKQuantitySample * weightSample;
    NSDictionary * metadata;

    NSArray *days = [jsonData objectForKey:@"body-bmi"];

    // Loop over days
    for(NSDictionary *day in days){
        double weight = [[day objectForKey:@"value"] doubleValue];
        NSString * date = [day objectForKey:@"dateTime"];
        DateStitch = AS(date,@" 12:00:00");
        sampleDate = [self stitchDateTime:DateStitch];

        // Create quantity type
        weightQuantity = [HKQuantity quantityWithUnit:unit doubleValue:weight];

        // Update bmi to mysql
        [self UpdateSQL:[day objectForKey:@"value"] type:@"Bmi" date1:[day objectForKey:@"dateTime"] insertTimestamp:@0 time1:@"12:00:00" time2:@"12:00:00" date2:[day objectForKey:@"dateTime"]];

        // Create sample and add to sample array
        metadata = [self ReturnMetadata:@"Bmi" date:DateStitch extra:nil];
        weightSample = [HKQuantitySample quantitySampleWithType:weightType quantity:weightQuantity startDate:sampleDate endDate:sampleDate device:[self ReturnDeviceInfo:nil] metadata:metadata];
        [sampleArray addObject:weightSample];
    }
    
    if([sampleArray count] > 0)
    {
        // Add to healthkit
        [hkstore saveObjects:sampleArray withCompletion:^(BOOL success, NSError *error){
            if(error){ NSLog(@"%@", error); }
        }];
    }
}

- (void) ProcessWeight:( NSDictionary *) jsonData
{
    NSString * DateStitch;
    NSDate * sampleDate;
    //
    // Define sample array
    NSMutableArray *sampleArray = [NSMutableArray array];
    
    // Healthkit unit and type declarations
    HKUnit *unit = [HKUnit unitFromString:@"kg"];
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKQuantity *weightQuantity;
    HKQuantitySample * weightSample;
    NSDictionary * metadata;

    NSArray *days = [jsonData objectForKey:@"body-weight"];

    // Loop over days
    for(NSDictionary *day in days){
        double weight = [[day objectForKey:@"value"] doubleValue];
        NSString * date = [day objectForKey:@"dateTime"];
        DateStitch = AS(date,@" 12:00:00");
        sampleDate = [self stitchDateTime:DateStitch];

        // Create quantity type
        weightQuantity = [HKQuantity quantityWithUnit:unit doubleValue:weight];

        // Update weight to mysql
        [self UpdateSQL:[day objectForKey:@"value"] type:@"Weight" date1:[day objectForKey:@"dateTime"] insertTimestamp:@0 time1:@"12:00:00" time2:@"12:00:00" date2:[day objectForKey:@"dateTime"]];

        // Create sample and add to sample array
        metadata = [self ReturnMetadata:@"Weight" date:DateStitch extra:nil];
        weightSample = [HKQuantitySample quantitySampleWithType:weightType quantity:weightQuantity startDate:sampleDate endDate:sampleDate device:[self ReturnDeviceInfo:nil] metadata:metadata];
        [sampleArray addObject:weightSample];
    }

    if([sampleArray count] > 0)
    {
        // Add to healthkit
        [hkstore saveObjects:sampleArray withCompletion:^(BOOL success, NSError *error){
            if(error){ NSLog(@"%@", error); }
        }];
    }
}

// Get nutrient details
- (void) ProcessNutrients:( NSDictionary *) jsonData
{
    // Get Date
    __block NSString * date;
    NSMutableDictionary *metadata;

    // Define sample array
    NSMutableArray *sampleArray = [NSMutableArray array];

    @try {
        NSArray * block = [jsonData objectForKey:@"foods"];
        date = [block[0] objectForKey:@"logDate"];
    }
    @catch (NSException *exception){
        return;
    }

    // Start date and stop date
    NSString * DateStitch = AS(date,@" 12:00:00");
    NSDate * sampleDate = [self stitchDateTime:DateStitch];

    // Get values
    NSDictionary * summary = [jsonData objectForKey:@"summary"];
    double carbs = [[summary objectForKey:@"carbs"] doubleValue];
    double fat = [[summary objectForKey:@"fat"] doubleValue];
    double fiber = [[summary objectForKey:@"fiber"] doubleValue];
    double protein = [[summary objectForKey:@"protein"] doubleValue];
    double sodium = [[summary objectForKey:@"sodium"] doubleValue];

    // Retrieve types
    HKUnit *unit = [HKUnit unitFromString:@"g"];
    HKQuantityType *carbsType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCarbohydrates];
    HKQuantityType *fatType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryFatTotal];
    HKQuantityType *fiberType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryFiber];
    HKQuantityType *proteinType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryProtein];
    HKQuantityType *sodiumType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietarySodium];

    // Create samples
    HKQuantity *carbsQuantity = [HKQuantity quantityWithUnit:unit doubleValue:carbs];
    HKQuantity *fatQuantity = [HKQuantity quantityWithUnit:unit doubleValue:fat];
    HKQuantity *fiberQuantity = [HKQuantity quantityWithUnit:unit doubleValue:fiber];
    HKQuantity *proteinQuantity = [HKQuantity quantityWithUnit:unit doubleValue:protein];
    HKQuantity *sodiumQuantity = [HKQuantity quantityWithUnit:unit doubleValue:sodium];

    // Carbs
    if(carbs != 0)
    {
        // Update carbs to mysql
        [self UpdateSQL:[summary objectForKey:@"carbs"] type:@"Carbs" date1:date insertTimestamp:@0 time1:@"12:00:00" time2:@"12:00:00" date2:date];
        metadata = [self ReturnMetadata:@"Carbs" date:DateStitch extra:nil];
        HKQuantitySample * carbsSample = [HKQuantitySample quantitySampleWithType:carbsType quantity:carbsQuantity startDate:sampleDate endDate:sampleDate device:[self ReturnDeviceInfo:nil] metadata:metadata];
        [sampleArray addObject:carbsSample];
    }

    // Fat
    if(fat != 0)
    {
        // Update fat to mysql
        [self UpdateSQL:[summary objectForKey:@"fat"] type:@"Fat" date1:date insertTimestamp:@0 time1:@"12:00:00" time2:@"12:00:00" date2:date];
        metadata = [self ReturnMetadata:@"Fat" date:DateStitch extra:nil];
        HKQuantitySample * fatSample = [HKQuantitySample quantitySampleWithType:fatType quantity:fatQuantity startDate:sampleDate endDate:sampleDate device:[self ReturnDeviceInfo:nil] metadata:metadata];
        [sampleArray addObject:fatSample];
    }

    // Fiber
    if(fiber != 0)
    {
        // Update fiber to mysql
        [self UpdateSQL:[summary objectForKey:@"fiber"] type:@"Fiber" date1:date insertTimestamp:@0 time1:@"12:00:00" time2:@"12:00:00" date2:date];
        metadata = [self ReturnMetadata:@"Fiber" date:DateStitch extra:nil];
        HKQuantitySample * fiberSample = [HKQuantitySample quantitySampleWithType:fiberType quantity:fiberQuantity startDate:sampleDate endDate:sampleDate device:[self ReturnDeviceInfo:nil] metadata:metadata];
        [sampleArray addObject:fiberSample];
    }

    // Protein
    if(protein != 0)
    {
        // Update protein to mysql
        [self UpdateSQL:[summary objectForKey:@"protein"] type:@"Protein" date1:date insertTimestamp:@0 time1:@"12:00:00" time2:@"12:00:00" date2:date];
        metadata = [self ReturnMetadata:@"Protein" date:DateStitch extra:nil];
        HKQuantitySample * proteinSample = [HKQuantitySample quantitySampleWithType:proteinType quantity:proteinQuantity startDate:sampleDate endDate:sampleDate device:[self ReturnDeviceInfo:nil] metadata:metadata];
        [sampleArray addObject:proteinSample];
    }

    //Sodium
    if(sodium != 0)
    {
        // Update sodium to mysql
        [self UpdateSQL:[summary objectForKey:@"sodium"] type:@"Sodium" date1:date insertTimestamp:@0 time1:@"12:00:00" time2:@"12:00:00" date2:date];
        metadata = [self ReturnMetadata:@"Sodium" date:DateStitch extra:nil];
        HKQuantitySample * sodiumSample = [HKQuantitySample quantitySampleWithType:sodiumType quantity:sodiumQuantity startDate:sampleDate endDate:sampleDate device:[self ReturnDeviceInfo:nil] metadata:metadata];
        [sampleArray addObject:sodiumSample];
    }

    // Update healthkit
    if([sampleArray count] > 0)
    {
        // Add to healthkit - carbs
        [hkstore saveObjects:sampleArray withCompletion:^(BOOL success, NSError *error){
            if(error){ NSLog(@"%@", error); }
        }];
    }
}


// Get calories burnt
- (void) ProcessCalories:( NSDictionary *) jsonData
{
    // Define sample array
    NSMutableArray *energyArray = [NSMutableArray array];

    // Access root container
    NSArray * out = [jsonData objectForKey:@"activities-calories"];
    NSDictionary * block = out[0];
    NSString * date = [block objectForKey:@"dateTime"];

    // Retrieve variables from json data
    NSDictionary * out2 = [jsonData objectForKey:@"activities-calories-intraday"];
    NSArray *out3 = [out2 objectForKey:@"dataset"];

    HKQuantityType *quantityType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKUnit *energy = [HKUnit unitFromString:@"cal"];

    for(NSDictionary * entry in out3){
        double value = [[entry objectForKey:@"value"] doubleValue];

        // Create date/time
        NSString * time = [entry objectForKey:@"time"];
        NSDate * dateTime = [self stitchDateTime:AS(AS(date,@" "),time)];

        NSDate *now = [NSDate date];
        NSNumber *nowEpochSeconds = [NSNumber numberWithInt:[now timeIntervalSince1970]];

        NSString *identifer = AS(AS(date,time),@"Calories");
        NSDictionary * metadata =
        @{HKMetadataKeySyncIdentifier: identifer,
          HKMetadataKeySyncVersion: nowEpochSeconds};

        // Create sample
        HKQuantity *quantity = [HKQuantity quantityWithUnit:energy doubleValue:value];
        HKQuantitySample * calSample = [HKQuantitySample quantitySampleWithType:quantityType quantity:quantity startDate:dateTime endDate:dateTime device:[self ReturnDeviceInfo:nil] metadata:metadata];

        // Add sample to array
        [energyArray addObject:calSample];
    }
    
    if([energyArray count] > 0){
        // Add to healthkit
        [hkstore saveObjects:energyArray withCompletion:^(BOOL success, NSError *error){
            if(error){ NSLog(@"%@", error); }
        }];
    }
}

// Get water drank
- (void) ProcessWater:( NSDictionary * ) jsonData
{
    // Create array for samples
    NSMutableArray *waterArray = [NSMutableArray array];

    // Create type
    HKQuantityType *quantityType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryWater];
    HKUnit *waterday = [HKUnit unitFromString:@"ml"];

    // Iterate over data
    NSArray * out = [jsonData objectForKey:@"foods-log-water"];
    for(NSDictionary * entry in out){
        NSString * date = [entry objectForKey:@"dateTime"];
        double value = [[entry objectForKey:@"value"] doubleValue];
        HKQuantity *quantity = [HKQuantity quantityWithUnit:waterday doubleValue:value];

        NSString * time2 = AS(date,@" 00:00:00");
        NSDate * dateTime1 = [self stitchDateTime:time2];

        NSString * time3 = AS(date,@" 23:59:59");
        NSDate * dateTime2 = [self stitchDateTime:time3];

        NSDate *now = [NSDate date];
        NSNumber *nowEpochSeconds = [NSNumber numberWithInt:[now timeIntervalSince1970]];

        NSString *identifer = AS(date,@"Water");
        NSDictionary * metadata =
        @{HKMetadataKeySyncIdentifier: identifer,
          HKMetadataKeySyncVersion: nowEpochSeconds};

        // Create sample
        HKQuantitySample * waterSample = [HKQuantitySample quantitySampleWithType:quantityType quantity:quantity startDate:dateTime1 endDate:dateTime2 device:[self ReturnDeviceInfo:nil] metadata:metadata];

        if(value != 0){
            [self UpdateSQL:[entry objectForKey:@"value"] type:@"Water" date1:date insertTimestamp:@0 time1:@"12:00:00" time2:@"12:00:00" date2:date];
            [waterArray addObject:waterSample];
        }
    }

    // Add to healthkit
    if([waterArray count] > 0)
    {
        [hkstore saveObjects:waterArray withCompletion:^(BOOL success, NSError *error){
            if(error){ NSLog(@"%@", error); }
        }];
    }
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
        // Update
        HKQuantity *restingHRquality = [HKQuantity quantityWithUnit:bpmd doubleValue:restingHR];
        HKQuantitySample * hrRestingSample = [HKQuantitySample quantitySampleWithType:restingtype quantity:restingHRquality startDate:dateTime1 endDate:dateTime3];

        // Update
        [self UpdateSQL:[block2 objectForKey:@"restingHeartRate"] type:@"RestingHR" date1:[self convertStringtoDate:dateTime1] insertTimestamp:@0 time1:@"0" time2:@"0" date2:[self convertStringtoDate:dateTime3]];

        
        // Insert into healthkit and return response error or success
        [hkstore saveObject:hrRestingSample withCompletion:^(BOOL success, NSError *error){
            if(error){ NSLog(@"%@", error); }
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
        
        if(value != 0){
            // Add sample to array
            [bpmArray addObject:hrSample];
        }
    }

    if([bpmArray count] > 0){
        // Add to healthkit
        [hkstore saveObjects:bpmArray withCompletion:^(BOOL success, NSError *error){
            if(error){ NSLog(@"%@", error); }
        }];
    }
}

// Floors walked
- (void) ProcessFloors:( NSDictionary * ) jsonData
{
    double floors;
    NSDate * startDateTime;
    NSDate * endDateTime;
    HKQuantity *quantity;
    NSDictionary * metadata;
    HKQuantitySample * floorSample;
    NSString * startDateString;
    
    // Define type
    HKQuantityType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed];
    
    // Define unit
    HKUnit *floorUnit = [HKUnit unitFromString:@"count"];
    
    // Retrieve date
    NSArray * out = [jsonData objectForKey:@"activities-floors"];
    NSDictionary * block = out[0];
    NSString * currentDate = [block objectForKey:@"dateTime"];
    
    // Access intraday data
    NSArray * stepsIntraday = [[jsonData objectForKey:@"activities-floors-intraday"] objectForKey:@"dataset"];
    
    double floorCount = 0;
    NSInteger count = 1;
    NSString * output = @"";
    
    // Present skips if needed
    for(int i=0; i< [self->skipArray count]; i++){
        if([self->skipArray[i]  isEqual: @"Floors"]){
            [self logText:@"Skipping Floors - Already inserted into healthkit"];
        }
    }
    
    // Iterate over results
    for(NSDictionary * entry in stepsIntraday){
        
        // Retrieve step count
        floors = [[entry objectForKey:@"value"] doubleValue];
        floorCount += floors;
        
        // Update array
        if(count % 4 == 0){
            
            if(count != 4){
                output = AS(output, @",");
            }
            
            // Add to output array string
            NSNumber *myDoubleNumber = [NSNumber numberWithDouble:floorCount];
            output = AS(output,[myDoubleNumber stringValue]);
            
            // Calculate date/time
            startDateString = AS(AS(currentDate, @" "),[entry objectForKey:@"time"]);
            startDateTime = [[self convertDate:startDateString] dateByAddingTimeInterval:-(45*60)];
            endDateTime = [startDateTime dateByAddingTimeInterval:60*60];
            
            // Create Sample
            metadata = [self ReturnMetadata:@"Floors" date:[self convertStringtoDate:startDateTime] extra:nil];
            quantity = [HKQuantity quantityWithUnit:floorUnit doubleValue:floorCount];
            
            floorSample = [HKQuantitySample quantitySampleWithType:stepType quantity:quantity startDate:startDateTime endDate:endDateTime metadata:metadata];
            
            // Insert into healthkit and return response error or success
            [hkstore saveObject:floorSample withCompletion:^(BOOL success, NSError *error){
                if(error){ NSLog(@"%@", error); }
            }];
            
            // Set stepcount to 0
            floorCount = 0;
        }
        count+=1;
    }
    
    // Add sample
    [self UpdateSQL:output type:@"Floors" date1:currentDate insertTimestamp:@0 time1:@"12:00:00" time2:@"12:00:00" date2:currentDate];

    // Flush
    output = @"";
        
}

// SQL method to update
- (void) UpdateSQL: (NSString *) value type:(NSString *) entity date1:(NSString *)date1 insertTimestamp:(NSNumber *) timestamp time1:(NSString *) time1 time2:(NSString *) time2 date2:(NSString *) date2
{
    // If date2 and time2 isnt used copy date and time to date2 and time2
    if(([date2  isEqual: @""] || date2 == nil) && ([time2  isEqual: @""] || time2 == nil)){
        date2 = date1;
        time2 = time1;
    }
    
    NSString *url = [NSString stringWithFormat:@"https://apple.rob-balmbra.co.uk/update.php?entity=%@&date=%@&value=%@&uid=%@&timestamp=%@&time=%@&date2=%@&time2=%@", entity, date1, value, self->userid, [timestamp stringValue], time1,date2,time2];

    NSString * encodeURL = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //NSLog(@"%@", encodeURL); //debug
    NSURL* url2 = [NSURL URLWithString:encodeURL];
    [NSData dataWithContentsOfURL:url2];
}

// Steps
- (void) ProcessSteps:( NSDictionary * ) jsonData
{
    double steps;
    NSDate * startDateTime;
    NSDate * endDateTime;
    HKQuantity *quantity;
    NSDictionary * metadata;
    HKQuantitySample * stepSample;
    NSString * startDateString;

    // Define type
    HKQuantityType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    // Define unit
    HKUnit *stepUnit = [HKUnit unitFromString:@"count"];

    // Retrieve date
    NSArray * out = [jsonData objectForKey:@"activities-steps"];
    NSDictionary * block = out[0];
    NSString * currentDate = [block objectForKey:@"dateTime"];
    
    // Access intraday data
    NSArray * stepsIntraday = [[jsonData objectForKey:@"activities-steps-intraday"] objectForKey:@"dataset"];

    double stepCount = 0;
    NSInteger count = 1;
    NSString * output = @"";
    
    // Present skips if needed
    for(int i=0; i< [self->skipArray count]; i++){
        if([self->skipArray[i]  isEqual: @"Steps"]){
            [self logText:@"Skipping Steps - Already inserted into healthkit"];
        }
    }
    
    // Iterate over results
    for(NSDictionary * entry in stepsIntraday){

        // Retrieve step count
        steps = [[entry objectForKey:@"value"] doubleValue];
        stepCount += steps;
        
        // Update array
        if(count % 4 == 0){
            
            if(count != 4){
                output = AS(output, @",");
            }
            
            // Add to output array string
            NSNumber *myDoubleNumber = [NSNumber numberWithDouble:stepCount];
            output = AS(output,[myDoubleNumber stringValue]);
            
            // Calculate date/time
            startDateString = AS(AS(currentDate, @" "),[entry objectForKey:@"time"]);
            startDateTime = [[self convertDate:startDateString] dateByAddingTimeInterval:-(45*60)];
            endDateTime = [startDateTime dateByAddingTimeInterval:60*60];

            // Create Sample
            metadata = [self ReturnMetadata:@"Steps" date:[self convertStringtoDate:startDateTime] extra:nil];
            quantity = [HKQuantity quantityWithUnit:stepUnit doubleValue:stepCount];
            stepSample = [HKQuantitySample quantitySampleWithType:stepType quantity:quantity startDate:startDateTime endDate:endDateTime metadata:metadata];
            
            // Insert into healthkit and return response error or success
            [hkstore saveObject:stepSample withCompletion:^(BOOL success, NSError *error){
                if(error){ NSLog(@"%@", error); }
            }];

            // Set stepcount to 0
            stepCount = 0;
        }
        count+=1;
    }
    
    // Add sample
    [self UpdateSQL:output type:@"Steps" date1:currentDate insertTimestamp:@0 time1:@"12:00:00" time2:@"12:00:00" date2:currentDate];
    
    // Flush
    output = @"";
}

// String -> Date (simple notation)
- (NSDate *)convertDate:(NSString *) Simpledate{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormat setFormatterBehavior:NSDateFormatterBehaviorDefault];
    NSDate *date = [dateFormat dateFromString:Simpledate];
    [dateFormat setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSString *finalStr = [dateFormat stringFromDate:date];
    NSDate *dateFromString = [dateFormat dateFromString:finalStr];
    return dateFromString;
}

// Date -> String (simple notation)
- (NSString *)convertStringtoDate:(NSDate *) Simpledate{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormat setFormatterBehavior:NSDateFormatterBehaviorDefault];
    NSString *date = [dateFormat stringFromDate:Simpledate];
    return date;
}

// String -> Date with Z
- (NSDate *)convertDateTimeZ:(NSString *) dateTime{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    [dateFormat setFormatterBehavior:NSDateFormatterBehaviorDefault];
    NSDate *date = [dateFormat dateFromString:dateTime];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSString *finalStr = [dateFormat stringFromDate:date];
    NSDate *dateFromString = [dateFormat dateFromString:finalStr];
    return dateFromString;
}

// String -> Date
- (NSDate *)convertDateTime:(NSString *) dateTime{
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
    [dateFormat setFormatterBehavior:NSDateFormatterBehaviorDefault];
    NSDate *date = [dateFormat dateFromString:dateTime];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSString *finalStr = [dateFormat stringFromDate:date];
    NSDate *dateFromString = [dateFormat dateFromString:finalStr];
    return dateFromString;
}

// Date -> String
- (NSString *)convertDateTimetoString:(NSDate *) dateTime{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
    [dateFormat setFormatterBehavior:NSDateFormatterBehaviorDefault];
    NSString *date = [dateFormat stringFromDate:dateTime];
    return date;
}

- (NSString *)convertDateToString:(NSDate * ) dateTime{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    [dateFormat setFormatterBehavior:NSDateFormatterBehaviorDefault];
    NSString *date = [dateFormat stringFromDate:dateTime];
    return date;
}

// Get json content from web server
- (NSArray *) GetHistoricData:(NSURL *)url{
    NSError *error = nil;
    NSString *content = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];

    NSData *jsonData = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *results = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error];
    return results;
}

// Method to get historic data
- (void) InstallHistoricData
{
    ////////////////////////////////////////////////// Steps /////////////////////////////////////////////////////
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://apple.rob-balmbra.co.uk/query.php?entity=%@&uid=%@", @"Steps", self->userid]];
    NSArray * results = [self GetHistoricData:url];
    
    // Only parse valid content
    if([results count] > 0){

        // Define type
        HKQuantityType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
        
        // Define unit
        HKUnit *stepUnit = [HKUnit unitFromString:@"count"];
        NSTimeInterval secondsInAnHour = 1 * 60 * 60;

        // Loop over entries - Iterate over days
        for(NSDictionary *entry in results){
            // Starting time
            NSString * Basedate = @"00:00:00";
            NSString * dates = AS(AS([entry objectForKey:@"datetime"],@" "),Basedate);
            NSDate * date = [self convertDate:dates];

            // Get values
            NSString * values = [entry objectForKey:@"value"];
            NSArray *items = [values componentsSeparatedByString:@","];

            for(NSString * value in items){

                // Get step value
                double stepCount = [value doubleValue];

                // Define quantity
                HKQuantity *quantity = [HKQuantity quantityWithUnit:stepUnit doubleValue:stepCount];

                // Get metadate for stopping duplication
                NSString * dateString = [self convertStringtoDate:date];
                NSDictionary * metadata = [self ReturnMetadata:@"Steps" date:dateString extra:nil];

                // Calculate end time
                NSDate * endtime = [date dateByAddingTimeInterval:secondsInAnHour];

                // Create sample
                HKQuantitySample * stepSample = [HKQuantitySample quantitySampleWithType:stepType quantity:quantity startDate:date endDate:endtime device:[self ReturnDeviceInfo:nil] metadata:metadata];
                
                // Insert into healthkit and return response error or success
                [hkstore saveObject:stepSample withCompletion:^(BOOL success, NSError *error){
                    if(error){ NSLog(@"%@", error); }
                }];
                
                date = [date dateByAddingTimeInterval:secondsInAnHour];
            }
        }
    }
    
    ////////////////////////////////////////////////// Sleep /////////////////////////////////////////////////////
    url = [NSURL URLWithString:[NSString stringWithFormat:@"https://apple.rob-balmbra.co.uk/query.php?entity=%@&uid=%@", @"Sleep", self->userid]];
    results = [self GetHistoricData:url];

    // Only parse valid content
    if([results count] > 0){

        // Define type
        HKCategoryType *sleepType = [HKCategoryType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
        
        // Define sample array
        NSMutableArray *sleepSamples = [NSMutableArray array];
        
        // Loop over entries
        for(NSDictionary *entry in results){
            NSDate * startDate = [self convertDateTime:[entry objectForKey:@"datetime"]];
            NSDate * endDate = [self convertDateTime:[entry objectForKey:@"datetime2"]];
            
            // Create metadata
            NSMutableDictionary * metadata = [self ReturnMetadata:@"Asleep" date:[entry objectForKey:@"datetime"] extra:nil];

            // Create sample
            HKCategorySample * sleepSample = [HKCategorySample categorySampleWithType:sleepType value:HKCategoryValueSleepAnalysisInBed startDate:startDate endDate:endDate device:[self ReturnDeviceInfo:nil] metadata:metadata];

            // Add to sample array
            [sleepSamples addObject:sleepSample];
        }

        if([sleepSamples count] > 0){
            // Insert into healthkit and return response error or success
            [hkstore saveObjects:sleepSamples withCompletion:^(BOOL success, NSError *error){
                if(error){ NSLog(@"%@", error); }
            }];
        }
    }

    ////////////////////////////////////////////////// Floors /////////////////////////////////////////////////////
    url = [NSURL URLWithString:[NSString stringWithFormat:@"https://apple.rob-balmbra.co.uk/query.php?entity=%@&uid=%@", @"Floors", self->userid]];
    results = [self GetHistoricData:url];

    // Only parse valid content
    if([results count] > 0){

        // Define type
        HKQuantityType *floorType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed];

        // Define unit
        HKUnit *stepUnit = [HKUnit unitFromString:@"count"];

        NSMutableArray *floorSamples = [NSMutableArray array];

        // Loop over entries
        for(NSDictionary *entry in results){
            double value = [[entry objectForKey:@"value"] doubleValue];
            NSString * time = [entry objectForKey:@"time"];
            NSString * dates = AS(AS([entry objectForKey:@"datetime"],@" "),time);
            NSDate * date = [self convertDate:dates];

            // Define quantity
            HKQuantity *quantity = [HKQuantity quantityWithUnit:stepUnit doubleValue:value];

            // Get metadate for stopping duplication
            NSMutableDictionary * metadata = [self ReturnMetadata:@"Floors" date:dates extra:nil];

            // Create Sample with step value
            HKQuantitySample * floorSample = [HKQuantitySample quantitySampleWithType:floorType quantity:quantity startDate:date endDate:date device:[self ReturnDeviceInfo:nil] metadata:metadata];

            // Add to sample array
            [floorSamples addObject:floorSample];
        }
        
        if([floorSamples count] > 0){
            // Insert into healthkit and return response error or success
            [hkstore saveObjects:floorSamples withCompletion:^(BOOL success, NSError *error){
                if(error){ NSLog(@"%@", error); }
            }];
        }
    }

    ////////////////////////////////////////////////// Weight /////////////////////////////////////////////////////
    url = [NSURL URLWithString:[NSString stringWithFormat:@"https://apple.rob-balmbra.co.uk/query.php?entity=%@&uid=%@", @"Weight", self->userid]];
    results = [self GetHistoricData:url];
    
    if([results count] > 0){

        // Define type
        HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
        
        // Define unit
        HKUnit *weightUnit = [HKUnit unitFromString:@"kg"];
        
        // Define samples array
        NSMutableArray *weightSamples = [NSMutableArray array];
        
        // Loop over entries
        for(NSDictionary *entry in results){
            double value = [[entry objectForKey:@"value"] doubleValue];
            NSString * time = [entry objectForKey:@"time"];
            NSString * dates = AS(AS([entry objectForKey:@"datetime"],@" "),time);
            NSDate * date = [self convertDate:dates];
            
            // Define quantity
            HKQuantity *quantity = [HKQuantity quantityWithUnit:weightUnit doubleValue:value];
            
            // Get metadate for stopping duplication
            NSMutableDictionary * metadata = [self ReturnMetadata:@"Weight" date:dates extra:nil];
            
            // Create Sample with step value
            HKQuantitySample * weightSample = [HKQuantitySample quantitySampleWithType:weightType quantity:quantity startDate:date endDate:date device:[self ReturnDeviceInfo:nil] metadata:metadata];
            
            // Add to sample array
            [weightSamples addObject:weightSample];
        }
        
        if([weightSamples count] > 0){
            // Insert into healthkit and return response error or success
            [hkstore saveObjects:weightSamples withCompletion:^(BOOL success, NSError *error){
                if(error){ NSLog(@"%@", error); }
            }];
        }
    }

    ////////////////////////////////////////////////// BMI /////////////////////////////////////////////////////
    url = [NSURL URLWithString:[NSString stringWithFormat:@"https://apple.rob-balmbra.co.uk/query.php?entity=%@&uid=%@", @"Bmi", self->userid]];
    results = [self GetHistoricData:url];

    if([results count] > 0){

        // Define type
        HKQuantityType *bmiType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMassIndex];

        // Define unit
        HKUnit *weightUnit = [HKUnit unitFromString:@"count"];

        // Define samples array
        NSMutableArray *bmiSamples = [NSMutableArray array];

        // Loop over entries
        for(NSDictionary *entry in results){
            double value = [[entry objectForKey:@"value"] doubleValue];
            NSString * time = [entry objectForKey:@"time"];
            NSString * dates = AS(AS([entry objectForKey:@"datetime"],@" "),time);
            NSDate * date = [self convertDate:dates];

            // Define quantity
            HKQuantity *quantity = [HKQuantity quantityWithUnit:weightUnit doubleValue:value];

            // Get metadate for stopping duplication
            
            NSMutableDictionary * metadata = [self ReturnMetadata:@"Bmi" date:dates extra:nil];

            // Create Sample with step value
            HKQuantitySample * bmiSample = [HKQuantitySample quantitySampleWithType:bmiType quantity:quantity startDate:date endDate:date device:[self ReturnDeviceInfo:nil] metadata:metadata];

            // Add to sample array
            [bmiSamples addObject:bmiSample];
        }

        if([bmiSamples count] > 0){
            // Insert into healthkit and return response error or success
            [hkstore saveObjects:bmiSamples withCompletion:^(BOOL success, NSError *error){
                if(error){ NSLog(@"%@", error); }
            }];
        }
    }

    // Completed
    [[NSUserDefaults standardUserDefaults] setBool:1 forKey:@"DataInstalled"];
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

        //Update
        [self UpdateSQL:@"0" type:@"Sleep" date1:[self convertDateTimetoString:startDate] insertTimestamp:@0 time1:@"0" time2:@"0" date2:[self convertDateTimetoString:endDate]];
        
        // Get start and end of sleep
        HKCategorySample * sleepSample = [HKCategorySample categorySampleWithType:sleepType value:HKCategoryValueSleepAnalysisInBed startDate:startDate endDate:endDate device:[self ReturnDeviceInfo:nil] metadata:metadata];

        // Insert into healthkit and return response error or success
        [hkstore saveObject:sleepSample withCompletion:^(BOOL success, NSError *error){
            if(error){ NSLog(@"%@", error); }
        }];
    }
}

- (BOOL) ArrayContains:(NSString *) DateString routeArray:(NSMutableArray *) routeArray
{
    BOOL isContains = 0;
    for(NSString * entry in routeArray){
        
        if([entry isEqualToString:DateString]){
            isContains = 1;
            break;
        }
    }
    return isContains;
}

// Get workout
- (HKWorkout *) GetWorkout:(NSDictionary *)entry
{
    __block NSUInteger workoutType = 0;
    __block HKWorkout *workout;
    __block NSUInteger workoutTypeIdentifer = 0;

    NSString * activityName = [entry objectForKey:@"activityName"];
    __block HKQuantity *totalDistance;
    __block NSString * model;

    // Select activity type
    if([activityName  isEqual: @"Walk"]){
        workoutType = HKWorkoutActivityTypeWalking;
        workoutTypeIdentifer = 0;
    }else if([activityName  isEqual: @"Outdoor Bike"]){
        workoutType = HKWorkoutActivityTypeCycling;
        workoutTypeIdentifer = 0;
    }else if([activityName isEqual: @"Run"]){
        workoutType = HKWorkoutActivityTypeRunning;
        workoutTypeIdentifer = 0;
    }else if([activityName isEqualToString:@"Hike"]){
        workoutType = HKWorkoutActivityTypeHiking;
        workoutTypeIdentifer = 0;
    }else if([activityName isEqualToString:@"Sport"]){
        workoutType = HKWorkoutActivityTypeOther;
        workoutTypeIdentifer = 0;
    }else if([activityName isEqualToString:@"Golf"]){
        workoutType = HKWorkoutActivityTypeGolf;
        workoutTypeIdentifer = 0;
    }else if([activityName isEqualToString:@"Swim"]){
        workoutType = HKWorkoutActivityTypeSwimming;
        workoutTypeIdentifer = 1;
    }else if([activityName isEqualToString:@"Tennis"]){
        workoutType = HKWorkoutActivityTypeTennis;
        workoutTypeIdentifer = 0;
    }else if([activityName isEqualToString:@"Elliptical"]){
        workoutType = HKWorkoutActivityTypeElliptical;
        workoutTypeIdentifer = 0;
    }else if([activityName isEqualToString:@"Kickboxing"]){
        workoutType = HKWorkoutActivityTypeKickboxing;
        workoutTypeIdentifer = 0;
    }else if([activityName isEqualToString:@"Pilates"]){
        workoutType = HKWorkoutActivityTypePilates;
        workoutTypeIdentifer = 0;
    }else if([activityName isEqualToString:@"Martial Arts"]){
        workoutType = HKWorkoutActivityTypeMartialArts;
        workoutTypeIdentifer = 0;
    }else if([activityName isEqualToString:@"Yoga"]){
        workoutType = HKWorkoutActivityTypeYoga;
        workoutTypeIdentifer = 0;
    }else if([activityName isEqualToString:@"Interval Workout"]){
        workoutTypeIdentifer = 0;
        workoutType = HKWorkoutActivityTypeHighIntensityIntervalTraining;
        workoutTypeIdentifer = 0;
    }else if([activityName isEqualToString:@"Circuit Training"]){
        workoutType = HKWorkoutActivityTypeCoreTraining;
        workoutTypeIdentifer = 0;
    }else if([activityName isEqualToString:@"Stairclimber"]){
        workoutType = HKWorkoutActivityTypeStairClimbing;
        workoutTypeIdentifer = 0;
    }else if([activityName isEqualToString:@"Weights"]){
        workoutType = HKWorkoutActivityTypeTraditionalStrengthTraining;
        workoutTypeIdentifer = 0;
    }else if([activityName isEqualToString:@"Spinning"]){
        workoutType = HKWorkoutActivityTypeBarre;
        workoutTypeIdentifer = 0;
    }else{
        workoutType = HKWorkoutActivityTypeOther;
        workoutTypeIdentifer = 0;
    }

    // Define extra meta options for workout
    NSMutableDictionary *MetaOptions = [[NSMutableDictionary alloc] init];

    // Elevation
    NSString *elevation = [entry objectForKey:@"elevationGain"];
    if(elevation != nil){
        if([elevation doubleValue] < 0){
            [MetaOptions setObject:elevation forKey:HKMetadataKeyElevationDescended];
        }else{
            [MetaOptions setObject:elevation forKey:HKMetadataKeyElevationAscended];
        }
    }

    // Steps
    NSString *steps = [entry objectForKey:@"steps"];
    if(steps != nil){
        [MetaOptions setObject:steps forKey:@"Step Count"];
    }

    // Pace
    NSString *pace = [entry objectForKey:@"pace"];
    if(pace != nil){
        [MetaOptions setObject:pace forKey:@"Pace"];
    }

    // Speed
    NSString *speed = [entry objectForKey:@"speed"];
    if(speed != nil){
        [MetaOptions setObject:speed forKey:HKMetadataKeyAverageSpeed];
    }

    // Distance
    double distance = [[entry objectForKey:@"distance"] doubleValue];
    if([entry objectForKey:@"distance"]  == nil){
        distance = 0;
        totalDistance = [HKQuantity quantityWithUnit:[HKUnit meterUnit] doubleValue:distance];
    }else{
        double conv = 0.621371;
        distance = (distance * conv);
        totalDistance = [HKQuantity quantityWithUnit:[HKUnit meterUnit] doubleValue:distance];
    }

    // Lap Length
    if([entry objectForKey:@"poolLength"] != nil){
        double poolLength = [[entry objectForKey:@"poolLength"] doubleValue];
        HKQuantity * poolLengthTotal = [HKQuantity quantityWithUnit:[HKUnit mileUnit] doubleValue:poolLength];
        [MetaOptions setObject:poolLengthTotal forKey:HKMetadataKeyLapLength];
    }

    // Create and declare calories type
    int calories = [[entry objectForKey:@"calories"] intValue];
    HKQuantity * totalCalories = [HKQuantity quantityWithUnit:[HKUnit smallCalorieUnit] doubleValue:calories];

    // Calculata EndDate and StartDate
    NSString * RawDateTime = [entry objectForKey:@"startTime"];
    NSDate * StartDate = [self convertDateTimeZ:[entry objectForKey:@"startTime"]];

    double duration = [[entry objectForKey:@"duration"] doubleValue];
    NSDate * EndDate = [StartDate dateByAddingTimeInterval:duration/1000.0];

    // Model Name
    if([entry objectForKey:@"source"] != nil){
        model = [[entry objectForKey:@"source"] objectForKey:@"name"];
    }else{
        model = nil;
    }

    //Alter distance to correct measurement - TODO
    if(workoutTypeIdentifer == 0){
        // Create generic workout
        NSDictionary * metadata = [self ReturnMetadata:@"Workout" date:RawDateTime extra:MetaOptions];
        workout = [HKWorkout workoutWithActivityType:workoutType
                                                       startDate:StartDate
                                                       endDate:EndDate
                                                       duration:0
                                                       totalEnergyBurned:totalCalories
                                                       totalDistance:totalDistance
                                                       device:[self ReturnDeviceInfo:model]
                                                       metadata:metadata];
    }else{
        // Create swimming workout
        NSDictionary * metadata = [self ReturnMetadata:@"Workout" date:RawDateTime extra:MetaOptions];
        workout = [HKWorkout workoutWithActivityType:workoutType
                                                        startDate:StartDate
                                                        endDate:EndDate
                                                        workoutEvents:nil
                                                        totalEnergyBurned:totalCalories
                                                        totalDistance:totalDistance
                                                        totalSwimmingStrokeCount:0
                                                        device:[self ReturnDeviceInfo:model]
                                                        metadata:metadata];
    }
    
    // Return workout
    return workout;
}

// Distance
- (void) ProcessWorkout:( NSDictionary * ) jsonData
{
    __block dispatch_group_t group2 = dispatch_group_create();

    NSArray * activities = [jsonData objectForKey:@"activities"];
    __block double distance;
    HKWorkout *workout;
    double averageHeartRate;

    typeof(self) __weak weakSelf = self;

    for(NSDictionary * entry in activities){

        dispatch_group_enter(group2);

        NSString * startDateRaw = [entry objectForKey:@"startTime"];
        NSDate * startTime = [self convertDateTimeZ:[entry objectForKey:@"startTime"]];
        NSString * activityName = [entry objectForKey:@"activityName"];

        distance = [[entry objectForKey:@"distance"] doubleValue];

        // Calculate end date/time
        double duration = [[entry objectForKey:@"duration"] doubleValue];
        NSDate * endTime = [startTime dateByAddingTimeInterval:duration/1000.0];

        //Average heart rate
        averageHeartRate = [[entry objectForKey:@"averageHeartRate"] doubleValue];

        // TxcFile
        NSString * httplink = [entry objectForKey:@"tcxLink"];

        // Create workout and return workout
        workout = [self GetWorkout:entry];

        if([self ArrayContains:[entry objectForKey:@"startTime"] routeArray:self->workoutArray]){
            [self logText:AS(AS(@"    Skipping workout `",activityName),@"` - Already installed.")];
            continue;
        }

        // Print activity type
        [self logText:AS(AS(@"    Parsing workout `", activityName),@"`.")];

        // Add workout
        [self->workoutArray addObject:[entry objectForKey:@"startTime"]];

        // Insert into healthkit and return response error or success
        [self->hkstore saveObject:workout withCompletion:^(BOOL success, NSError *error){
            if(success) {
                // Check if distance exists to see if gps is available
                if([entry objectForKey:@"tcxLink"] != nil && [entry objectForKey:@"distance"] != nil){
                    
                    dispatch_group_t group = dispatch_group_create();
                    //NSLog(@"%@", httplink);
                    [self ProcessTCX:httplink group:group completion:^(NSDictionary * xml, NSError * error) {
                        
                        // Define heartrate type
                        HKQuantityType *heartType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
                        
                        // Defined heartrate unit
                        HKUnit *bpm = [HKUnit unitFromString:@"count/min"];
                        
                        // Get Latitude/Longitude array
                        NSArray * points = [[[[[[xml objectForKey:@"TrainingCenterDatabase"] objectForKey:@"Activities"] objectForKey:@"Activity"] objectForKey:@"Lap"] objectForKey:@"Track"] objectForKey:@"Trackpoint"];

                        // Safety net, some activities may have distance set but doesnt have gps and/or within the file
                        if([points count] > 0){
                            
                            // Define route location array
                            __block NSMutableArray *heartArray = [NSMutableArray array];
                            __block NSMutableArray *routeArray = [NSMutableArray array];
                            
                            // Retrieve lat/long on each point
                            for(NSDictionary * latlong in points){
                                NSDictionary * container = [latlong objectForKey:@"Position"];

                                double latitude = [[[container objectForKey:@"LatitudeDegrees"] objectForKey:@"text"] doubleValue];
                                double longitude = [[[container objectForKey:@"LongitudeDegrees"] objectForKey:@"text"] doubleValue];
                                double altitude = [[[latlong objectForKey:@"AltitudeMeters"] objectForKey:@"text"] doubleValue];

                                // Timestamp
                                NSDate * timestamp = [self convertDateTimeZ:[[latlong objectForKey:@"Time"] objectForKey:@"text"]];
                                
                                
                                double HeartRateBpm = [[[[latlong objectForKey:@"HeartRateBpm"] objectForKey:@"Value"] objectForKey:@"text"] doubleValue];
                                HKQuantity *quantity = [HKQuantity quantityWithUnit:bpm doubleValue:HeartRateBpm];
                                
                                // Create sample
                                HKQuantitySample * hrSample = [HKQuantitySample quantitySampleWithType:heartType quantity:quantity startDate:timestamp endDate:timestamp];
                                
                                // Add to sample array
                                [heartArray addObject:hrSample];

                                CLLocation *test = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude) altitude:altitude horizontalAccuracy:-1 verticalAccuracy:-1 timestamp:timestamp];

                                // Add to route array
                                [routeArray addObject:test];
                            }
                            
                            if([heartArray count] == 0 && [routeArray count] == 0){
                                dispatch_group_leave(group2);
                            }else if([heartArray count] == 0){
                                // Do nothing
                            }else{
                                // Insert into healthkit
                                [self->hkstore addSamples:heartArray toWorkout:workout completion:^(BOOL success, NSError *error) {
                                    if(error){ NSLog(@"%@", error); }
                                    
                                    if([routeArray count] == 0){
                                        dispatch_group_leave(group2);
                                    }
                                }];
                            }
                            
                            // Add GPS to workout
                            if([routeArray count] > 0){
                                
                                // Declare route builder
                                HKWorkoutRouteBuilder *routeBuilder = [[HKWorkoutRouteBuilder alloc] initWithHealthStore:self->hkstore device:[self ReturnDeviceInfo:nil]];
                                
                                [routeBuilder insertRouteData:routeArray completion:^(BOOL success, NSError * _Nullable error) {
                                    if(error){
                                        dispatch_group_leave(group2);
                                    }else{
                                        NSMutableDictionary * metadata = [self ReturnMetadata:@"WorkoutRoute" date:startDateRaw extra:nil];
                                        [routeBuilder finishRouteWithWorkout:workout metadata:(metadata) completion:^(HKWorkoutRoute * _Nullable workoutRoute, NSError * _Nullable error) {
                                            dispatch_group_leave(group2);
                                        }];
                                    }
                                }];
                            }
                        }else{
                            dispatch_group_leave(group2);
                        }
                    }];
                }else{
                    if(averageHeartRate != 0){
                        
                        NSMutableArray *averageHeartRateArray = [NSMutableArray array];
                        HKQuantityType *heartRateAverageType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
                        HKQuantity *heartRateAverageForInterval = [HKQuantity quantityWithUnit:[HKUnit unitFromString:@"count/min"] doubleValue:averageHeartRate];
                        
                        // Create sample
                        HKQuantitySample *heartRateAverageForIntervalSample = [HKQuantitySample quantitySampleWithType:heartRateAverageType
                                                            quantity:heartRateAverageForInterval
                                                            startDate:startTime
                                                            endDate:endTime];
                        
                        [averageHeartRateArray addObject:heartRateAverageForIntervalSample];
                        [self->hkstore addSamples:averageHeartRateArray toWorkout:workout completion:^(BOOL success, NSError * _Nullable error) {
                            dispatch_group_leave(group2);
                        }];
                    }else{
                        dispatch_group_leave(group2);
                    }
                }
            }
        }];
    }
    
    dispatch_group_notify(group2, dispatch_get_main_queue(), ^{
        self->workoutComplete = 1;
    });
    
}

-(void)showAlert :(NSString *)message{
    UIWindow* window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.rootViewController = [UIViewController new];
    window.windowLevel = UIWindowLevelAlert + 1;
    
    UIAlertController* alertView = [UIAlertController alertControllerWithTitle:@"Fitbit Error!" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alertView addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        window.hidden = YES;
    }]];
    
    [window makeKeyAndVisible];
    [window.rootViewController presentViewController:alertView animated:YES completion:nil];
}

-(BOOL)isInstalled{

    // Check if historic data has been queried and installed
    BOOL state = [[NSUserDefaults standardUserDefaults] boolForKey:@"DataInstalled"];
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"DataInstalled"] == nil) {
        // Not installed
        return 0;
    }else  if (state == false) {
        // Not installed
        return 0;
    }else{
        // Installed
        return 1;
    }
}

- (void) ProcessTCX :( NSString * ) url group:(dispatch_group_t)group completion:(ButtonCompletionBlock)completionBlock
{
    // Enter group
    dispatch_group_enter(group);
    
    NSString *token = [FitbitAuthHandler getToken];
    FitbitAPIManager *manager = [FitbitAPIManager sharedManager];
    
    // Get URL
    [manager requestGET:url xml:1 Token:token success:^(NSDictionary *responseObject) {
        
        // Return json dict
        completionBlock(responseObject,nil);
    
        // Leave
        dispatch_group_leave(group);
        
    } failure:^(NSError *error) {
        
        // Return error
        completionBlock(nil,error);
    
        // Leave
        dispatch_group_leave(group);

    }];
}

-(void)getFitbitUserID{
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] != nil) {
        // Copy userid from NSUserDefaults if exits
        NSUserDefaults *data = [NSUserDefaults standardUserDefaults];
        self->userid = [data objectForKey:@"userid"];
        dispatch_group_leave(group);
    }else{
        // Get userid from URL
        NSString *token = [FitbitAuthHandler getToken];
        FitbitAPIManager *manager = [FitbitAPIManager sharedManager];
        
        NSString * url = @"https://api.fitbit.com/1/user/-/profile.json";
        [manager requestGET:url xml:0 Token:token success:^(NSDictionary *responseObject) {

            // Get user id
            NSDictionary * data = [responseObject objectForKey:@"user"];
            NSString * userid = [data objectForKey:@"encodedId"];
            self->userid = userid;
            
            // Set id in NSUSERDEFAULTS for future use
            [[NSUserDefaults standardUserDefaults] setValue:userid forKey:@"userid"];
            
            // Leave
            dispatch_group_leave(group);
            
        } failure:^(NSError *error) {
            NSData * errorData = (NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
            NSDictionary *errorResponse =[NSJSONSerialization JSONObjectWithData:errorData options:NSJSONReadingAllowFragments error:nil];
            NSArray *errors = [errorResponse valueForKey:@"errors"];
            NSString *errorType = [[errors objectAtIndex:0] valueForKey:@"errorType"];
            if ([errorType isEqualToString:fInvalid_Client] || [errorType isEqualToString:fExpied_Token] || [errorType isEqualToString:fInvalid_Token]|| [errorType isEqualToString:fInvalid_Request]) {
                // To perform login if token is expired
                [self->fitbitAuthHandler login:self];
                return;
            }

            // Leave
            dispatch_group_leave(group);
        }];
    }

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if(![self->userid isEqual: @""]){
            // Initial historic data install using userid only once
            if([self isInstalled] == 0){
                [self InstallHistoricData];
            }

            self->running = 1;
            
            if(self->apiNoRequests == 1){
                self->resultView.textColor = [UIColor redColor];
            }else{
                if(self->isDarkMode == 1){
                    self->resultView.textColor = [UIColor whiteColor];
                }else{
                    self->resultView.textColor = [UIColor blackColor];
                }
            }
            
            // Get user pref and urls, then process
            [self generateURLS];

        }else{
            [self logText:@"Too many requests, try again later..."];
            self->resultView.text = @"Too many requests, try again later...";
            self->ProgressBar.hidden = true;
            self->resultView.textColor = [UIColor redColor];
            self->running = 0;
        }
    });
}

- (void)timerCallback:(NSTimer*)theTimer
{
    if(self->foundWorkout == 1 && self->workoutComplete == 1){
        
        self->progress+=self->count;
        self->ProgressBar.progress = (float)self->progress;
        
        [self logText:@"Sync Complete"];
        [theTimer invalidate];
        
        self->resultView.text = @"Sync Complete";
        self->running = 0;
    }else{
        self->progress+=self->count;
        self->ProgressBar.progress = (float)self->progress;
        
        [self logText:@"Sync Complete"];
        [theTimer invalidate];
        
        self->resultView.text = @"Sync Complete";
        self->running = 0;
    }
}

// Pass URL and return json from fitbit API
-(void)getFitbitURL{

    // Create dispatch block
    dispatch_group_t group = dispatch_group_create();
    
    
    self->foundWorkout = 0;
    __block NSMutableArray * prevTypes = [[NSMutableArray alloc] init];
    
    // Iterate over URLS
    NSMutableArray *URLS = self->urlArray;
    for (NSMutableArray *entity in URLS){
        
        if(self->apiNoRequests == 1){
            break;
        }

        // Retrieve url and activity type
        NSString *url = entity[0];
        __block NSString *type = entity[1];
        
        if([type  isEqual: @"workout"]){
            self->foundWorkout = 1;
        }
        
        // Enter group
        dispatch_group_enter(group);

        NSString *token = [FitbitAuthHandler getToken];
        FitbitAPIManager *manager = [FitbitAPIManager sharedManager];
        
        // Get URL
        [manager requestGET:url xml:0 Token:token success:^(NSDictionary *responseObject) {

            // Update interface with message, passed from entity
            if(self->apiNoRequests == 0){
                
                self->progress+=self->count;
                self->ProgressBar.progress = (float)self->progress;
                
                // Skip processing if in loop
                if([self ArrayContains:type routeArray:prevTypes]){
                    //ignore
                }else{
                    self->resultView.text = [[@"Processing `" stringByAppendingString:type] stringByAppendingString:@"` data..."];
                    NSString * output = [[@"Processing `" stringByAppendingString:type] stringByAppendingString:@"` data..."];
                    [self logText:output];
                    
                    // Print out skips
                    for(int i=0; i<[self->skipArray count]; i++){
                        if([self->skipArray[i] isEqualToString: type]){
                            [self logText:AS(AS(@"Skipping ", type),@" - Already inserted into healthkit")];
                        }
                    }
                    
                    // Only display prompt once
                    [prevTypes addObject:type];
                }
                
                // Pass data to individual methods for processing
                NSString *methodName = AS(@"Process",[[type capitalizedString] stringByReplacingOccurrencesOfString:@" " withString:@""]);
                NSString *methodArgs = AS(methodName,@":");

                //Only accept valid json response
                if([responseObject count] != 0){
                    @try{
                        // Retrieve method for selected activity
                        SEL doubleParamSelector = NSSelectorFromString(methodArgs);
                        [self performSelector: doubleParamSelector withObject: responseObject];
                    }
                    @catch (NSException *exception){
                        // Catch if failed
                        NSString * methodError = AS(AS(@"Error - Failed to find method `",methodName),@"`.");
                        NSLog(@"%@", exception);
                        [self logText:methodError];
                    }
                }
            }else{
                self->ProgressBar.hidden = true;
            }

            // Leave group
            dispatch_group_leave(group);

        } failure:^(NSError *error) {
            NSData * errorData = (NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
            NSDictionary *errorResponse =[NSJSONSerialization JSONObjectWithData:errorData options:NSJSONReadingAllowFragments error:nil];
            NSArray *errors = [errorResponse valueForKey:@"errors"];
            NSString *errorType = [[errors objectAtIndex:0] valueForKey:@"errorType"];
            if ([errorType isEqualToString:fInvalid_Client] || [errorType isEqualToString:fExpied_Token] || [errorType isEqualToString:fInvalid_Token]|| [errorType isEqualToString:fInvalid_Request]) {
                // To perform login if token is expired
                [self->fitbitAuthHandler login:self];
                return;
            }
            
            // Detect too many requests
            NSString *message = [[errors objectAtIndex:0] valueForKey:@"message"];
            if([message isEqual: @"Too Many Requests"] || errors == nil){
                NSDate *now = [NSDate date];
                NSInteger nowEpochSeconds = [now timeIntervalSince1970];
                
                NSInteger new_number = nowEpochSeconds - (nowEpochSeconds % 3600);
                NSInteger nearestHour = (new_number + 3600) + 15;

                // Save nearest hour
                [[NSUserDefaults standardUserDefaults] setInteger:nearestHour forKey:@"nowEpochSeconds"];

                self->running = 0;
                self->resultView.textColor = [UIColor redColor];

                [self logText:@"Too many requests, try again later..."];
                self->resultView.textColor = [UIColor redColor];
                self->resultView.text = @"Too many requests, try again later...";
                self->ProgressBar.hidden = true;
                self->running = 0;
                self->apiNoRequests = 1;
            }else{
                if(self->isDarkMode == 1){
                    self->resultView.textColor = [UIColor whiteColor];
                }else{
                    self->resultView.textColor = [UIColor blackColor];
                }
                
                self->running = 1;
                self->apiNoRequests = 0;
                self->nearestHour = -1;
            }

            dispatch_group_leave(group);
        }];
    }

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if(self->apiNoRequests == 0){

            //Loop
            self->timer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(timerCallback:) userInfo:nil repeats:YES];
            
            NSRunLoop *runloop = [NSRunLoop currentRunLoop];
            [runloop addTimer:self->timer forMode:NSDefaultRunLoopMode];
        }else{
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            self->ProgressBar.hidden = true;
            [defaults setValue:@"Sync Started...\nToo many requests, try again later..." forKey:@"OutputLog"];
            self->running = 0;
        }
    });
}

-(BOOL)checkNetConnection
{
    Reachability * reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus] ;
    
    if(internetStatus == NotReachable)
    {
        return NO;
    }
    else {
        // NSLog(@"Network is reachable");
        return YES;
    }
}

- (IBAction)actionLogin:(UIButton *)sender {
    
    if(self->running == 1){
        return;
    }else{
        self->progress = 0;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:@"" forKey:@"OutputLog"];
        
        [self logText:@"Sync Started..."];
        self->running = 1;
    }
    
    // Check if internet available
    BOOL isNetworkAvailable = [self checkNetConnection];
    if (!isNetworkAvailable) {
        [self logText:@"Please check your internet connection"];
        [self showAlert:@"Please check your internet connection"];
        return;
    }

    NSDate *now = [NSDate date];
    NSInteger nowEpochSeconds = [now timeIntervalSince1970];
    NSInteger nearestHour = [[NSUserDefaults standardUserDefaults] integerForKey:@"nowEpochSeconds"];
    
    self->nearestHour = nearestHour;
    if(self->nearestHour != -1 && nowEpochSeconds > self->nearestHour)
    {
        self->apiNoRequests = 0;
        self->nearestHour = -1;
        self->ProgressBar.hidden = true;
    }else{
        self->apiNoRequests = 1;
        self->ProgressBar.hidden = true;
        [self logText:@"Too many requests, try again later..."];
        self->resultView.text = @"Too many requests, try again later...";
        self->resultView.textColor = [UIColor redColor];
        self->running = 0;
        return;
    }

    if(self->apiNoRequests == 1){
        self->ProgressBar.hidden = true;
        [self logText:@"Too many requests, try again later..."];
        self->resultView.text = @"Too many requests, try again later...";
        self->resultView.textColor = [UIColor redColor];
        self->running = 0;
        return;
    }else{
        self->ProgressBar.hidden = false;
        self->resultView.text = @"";
        if(self->isDarkMode == 1){
            self->resultView.textColor = [UIColor whiteColor];
        }else{
            self->resultView.textColor = [UIColor blackColor];
        }
    }

    // Write types attributes
    NSArray *writeTypes = @[
                            [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
                            [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate],
                            [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierRestingHeartRate],
                            [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryWater],
                            [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed],
                            [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis],
                            [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned],
                            [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCarbohydrates],
                            [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietarySodium],
                            [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryFiber],
                            [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryFatTotal],
                            [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryProtein],
                            [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass],
                            [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMassIndex],
                            [HKObjectType workoutType],
                            [HKSeriesType workoutRouteType]
                            ];
    
    NSArray *readTypes = @[
                           [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
                           [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate],
                           [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierRestingHeartRate],
                           [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryWater],
                           [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed],
                           [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis],
                           [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned],
                           [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCarbohydrates],
                           [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietarySodium],
                           [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryFiber],
                           [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryFatTotal],
                           [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryProtein],
                           [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass],
                           [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMassIndex],
                           [HKObjectType workoutType],
                           [HKSeriesType workoutRouteType]
                           ];
    
    
        hkstore = [[HKHealthStore alloc] init];
        [hkstore requestAuthorizationToShareTypes:[NSSet setWithArray:writeTypes]
                                        readTypes:[NSSet setWithArray:readTypes]
                                        completion:^(BOOL success, NSError * _Nullable error) {

        if(error){
            [self logText:error];
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

            // Water
            if(self->waterSwitch){
                HKObjectType *water = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryWater];
                HKAuthorizationStatus waterStatus = [self->hkstore authorizationStatusForType:water];
                errorCount += [self checktype:waterStatus];
            }

            // Energy
            if(self->activeEnergy){
                HKObjectType *energy = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
                HKAuthorizationStatus energyStatus = [self->hkstore authorizationStatusForType:energy];
                errorCount += [self checktype:energyStatus];
            }

            // Nutrients
            if(self->nutrients){
                // Carbs
                HKObjectType *carbs = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCarbohydrates];
                HKAuthorizationStatus carbsStatus = [self->hkstore authorizationStatusForType:carbs];
                errorCount += [self checktype:carbsStatus];

                // Fat
                HKObjectType *fat = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryFatTotal];
                HKAuthorizationStatus fatStatus = [self->hkstore authorizationStatusForType:fat];
                errorCount += [self checktype:fatStatus];

                //Fiber
                HKObjectType *fiber = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryFiber];
                HKAuthorizationStatus fiberStatus = [self->hkstore authorizationStatusForType:fiber];
                errorCount += [self checktype:fiberStatus];

                // Sodium
                HKObjectType *sodium = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietarySodium];
                HKAuthorizationStatus sodiumStatus = [self->hkstore authorizationStatusForType:sodium];
                errorCount += [self checktype:sodiumStatus];

                //Protein
                HKObjectType *protein = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryProtein];
                HKAuthorizationStatus proteinStatus = [self->hkstore authorizationStatusForType:protein];
                errorCount += [self checktype:proteinStatus];
            }
            
            if(self->distanceSwitch){
                HKObjectType *workoutType = [HKObjectType workoutType];
                HKAuthorizationStatus workoutTypeStatus = [self->hkstore authorizationStatusForType:workoutType];
                errorCount += [self checktype:workoutTypeStatus];
                
                HKSeriesType *workoutRouteType = [HKSeriesType workoutRouteType];
                HKAuthorizationStatus workoutRouteTypeStatus = [self->hkstore authorizationStatusForType:workoutRouteType];
                errorCount += [self checktype:workoutRouteTypeStatus];
            }

            // Weight
            if(self->weightSwitch){
                HKObjectType *weight = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
                HKAuthorizationStatus weightStatus = [self->hkstore authorizationStatusForType:weight];
                errorCount += [self checktype:weightStatus];

                HKObjectType *bmi = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMassIndex];
                HKAuthorizationStatus bmiStatus = [self->hkstore authorizationStatusForType:bmi];
                errorCount += [self checktype:bmiStatus];
            }

            if(errorCount != 0){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self logText:@"Please go to the Apple Health app, and give access to all the types."];
                    self->resultView.text = @"Please go to the Apple Health app, and give access to all the types.";
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
    
                // Only run safari fitbit auth once
                if(self->launchedFitAuth == 0){
                    [self->fitbitAuthHandler login:self];
                    self->launchedFitAuth = 1;
                }else{
                    [self notificationDidReceived];
                }
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
        [self logText:@"Please press login to authorize"];
        resultView.text = @"Please press login to authorize";
    }
}

@end
