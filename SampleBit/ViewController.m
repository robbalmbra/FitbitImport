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
    __block BOOL isRed;
    __block BOOL isDarkMode;
    __block BOOL apiNoRequests;
    __block NSInteger nearestHour;
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
    
    self->apiNoRequests = 0;
    self->nearestHour = -1;
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
    NSString *startDate = [self calcDate:3];
    NSString *endDate = [self dateNow];
    NSString *entity;
    NSString *url;
    
    // How many days to process (today - Days);
    NSInteger Days = 3;
    int i = 0;
    
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
        for(i=0; i<Days; i++){
            NSString *dateNow = [self calcDate:i];
            url = [NSString stringWithFormat:@"https://api.fitbit.com/1/user/-/activities/heart/date/%@/1d/1min.json",dateNow];
            entity = [NSString stringWithFormat:@"heart rate"];
            [array addObject:[NSMutableArray arrayWithObjects:url,entity,nil]];
        }
    }

    //////////////////////////////////////////////// Water Consumed ///////////////////////////////////////////////
    if(waterSwitch){
        url = [NSString stringWithFormat:@"https://api.fitbit.com/1/user/-/foods/log/water/date/%@/%@.json",startDate, endDate];
        entity = [NSString stringWithFormat:@"water"];
        [array addObject:[NSMutableArray arrayWithObjects:url,entity,nil]];
    }
    
    ////////////////////////////////////////////////// Energy /////////////////////////////////////////////////////
    if(activeEnergy){
        for(i=0; i<Days; i++){
            NSString *dateNow = [self calcDate:i];
            url = [NSString stringWithFormat:@"https://api.fitbit.com/1/user/-/activities/calories/date/%@/1d/15min.json",dateNow];
            entity = [NSString stringWithFormat:@"calories"];
            [array addObject:[NSMutableArray arrayWithObjects:url,entity,nil]];
        }
    }

    ///////////////////////////////////////////////// Food properties /////////////////////////////////////////////
    if(nutrients){
        for(i=0; i<Days; i++){
            NSString *dateNow = [self calcDate:i];
            url = [NSString stringWithFormat:@"https://api.fitbit.com/1/user/-/foods/log/date/%@.json",dateNow];
            entity = [NSString stringWithFormat:@"nutrients"];
            [array addObject:[NSMutableArray arrayWithObjects:url,entity,nil]];
        }
    }
    
    ///////////////////////////////////////////////////// Weight ///////////////////////////////////////////////////
    if(weightSwitch){
        url = [NSString stringWithFormat:@"https://api.fitbit.com/1/user/-/body/weight/date/%@/%@.json",startDate, endDate];
        entity = [NSString stringWithFormat:@"weight"];
        [array addObject:[NSMutableArray arrayWithObjects:url,entity,nil]];
        
        url = [NSString stringWithFormat:@"https://api.fitbit.com/1/user/-/body/bmi/date/%@/%@.json",startDate, endDate];
        entity = [NSString stringWithFormat:@"bmi"];
        [array addObject:[NSMutableArray arrayWithObjects:url,entity,nil]];
    }
    // Return array
    return array;
}

-(void)notificationDidReceived{
    // Initial message, starting to sync
    if(self->apiNoRequests == 0){
        resultView.text = @"Syncing data started...";

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

// Return metadata to avoid duplication of data
- (NSDictionary *) ReturnMetadata:(NSString *) type date:(NSString *) date
{
    NSDate *now = [NSDate date];
    NSNumber *nowEpochSeconds = [NSNumber numberWithInt:[now timeIntervalSince1970]];
    
    NSString *identifer = AS(date,type);
    NSDictionary * metadata =
    @{HKMetadataKeySyncIdentifier: identifer,
      HKMetadataKeySyncVersion: nowEpochSeconds};
    
    return metadata;
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

        // Update
        [self UpdateSQL:[day objectForKey:@"value"] type:@"Bmi" date1:[day objectForKey:@"dateTime"] insertTimestamp:@0 time1:@"12:00:00" time2:@"12:00:00" date2:[day objectForKey:@"dateTime"]];

        // Create sample and add to sample array
        metadata = [self ReturnMetadata:@"Bmi" date:DateStitch];
        weightSample = [HKQuantitySample quantitySampleWithType:weightType quantity:weightQuantity startDate:sampleDate endDate:sampleDate metadata:metadata];
        [sampleArray addObject:weightSample];
    }
    
    if([sampleArray count] > 0)
    {
        // Add to healthkit
        [hkstore saveObjects:sampleArray withCompletion:^(BOOL success, NSError *error){
            if(success) {
                //NSLog(@"success");
            }else {
                NSLog(@"%@", error);
            }
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

        // Update
        [self UpdateSQL:[day objectForKey:@"value"] type:@"Weight" date1:[day objectForKey:@"dateTime"] insertTimestamp:@0 time1:@"12:00:00" time2:@"12:00:00" date2:[day objectForKey:@"dateTime"]];

        // Create sample and add to sample array
        metadata = [self ReturnMetadata:@"Weight" date:DateStitch];
        weightSample = [HKQuantitySample quantitySampleWithType:weightType quantity:weightQuantity startDate:sampleDate endDate:sampleDate metadata:metadata];
        [sampleArray addObject:weightSample];
    }

    if([sampleArray count] > 0)
    {
        // Add to healthkit
        [hkstore saveObjects:sampleArray withCompletion:^(BOOL success, NSError *error){
            if(success) {
                //NSLog(@"success");
            }else {
                NSLog(@"%@", error);
            }
        }];
    }
}

// Get nutrient details
- (void) ProcessNutrients:( NSDictionary *) jsonData
{
    // Get Date
    __block NSString * date;
    NSDictionary *metadata;

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
        [self UpdateSQL:[summary objectForKey:@"carbs"] type:@"Carbs" date1:date insertTimestamp:@0 time1:@"12:00:00" time2:@"12:00:00" date2:date];
        metadata = [self ReturnMetadata:@"Carbs" date:DateStitch];
        HKQuantitySample * carbsSample = [HKQuantitySample quantitySampleWithType:carbsType quantity:carbsQuantity startDate:sampleDate endDate:sampleDate metadata:metadata];
        [sampleArray addObject:carbsSample];
    }

    // Fat
    if(fat != 0)
    {
        [self UpdateSQL:[summary objectForKey:@"fat"] type:@"Fat" date1:date insertTimestamp:@0 time1:@"12:00:00" time2:@"12:00:00" date2:date];
        metadata = [self ReturnMetadata:@"Fat" date:DateStitch];
        HKQuantitySample * fatSample = [HKQuantitySample quantitySampleWithType:fatType quantity:fatQuantity startDate:sampleDate endDate:sampleDate metadata:metadata];
        [sampleArray addObject:fatSample];
    }

    // Fiber
    if(fiber != 0)
    {
        [self UpdateSQL:[summary objectForKey:@"fiber"] type:@"Fiber" date1:date insertTimestamp:@0 time1:@"12:00:00" time2:@"12:00:00" date2:date];
        metadata = [self ReturnMetadata:@"Fiber" date:DateStitch];
        HKQuantitySample * fiberSample = [HKQuantitySample quantitySampleWithType:fiberType quantity:fiberQuantity startDate:sampleDate endDate:sampleDate metadata:metadata];
        [sampleArray addObject:fiberSample];
    }

    // Protein
    if(protein != 0)
    {
        [self UpdateSQL:[summary objectForKey:@"protein"] type:@"Protein" date1:date insertTimestamp:@0 time1:@"12:00:00" time2:@"12:00:00" date2:date];
        metadata = [self ReturnMetadata:@"Protein" date:DateStitch];
        HKQuantitySample * proteinSample = [HKQuantitySample quantitySampleWithType:proteinType quantity:proteinQuantity startDate:sampleDate endDate:sampleDate metadata:metadata];
        [sampleArray addObject:proteinSample];
    }

    //Sodium
    if(sodium != 0)
    {
        [self UpdateSQL:[summary objectForKey:@"sodium"] type:@"Sodium" date1:date insertTimestamp:@0 time1:@"12:00:00" time2:@"12:00:00" date2:date];
        metadata = [self ReturnMetadata:@"Sodium" date:DateStitch];
        HKQuantitySample * sodiumSample = [HKQuantitySample quantitySampleWithType:sodiumType quantity:sodiumQuantity startDate:sampleDate endDate:sampleDate metadata:metadata];
        [sampleArray addObject:sodiumSample];
    }

    if([sampleArray count] > 0)
    {
        // Add to healthkit - carbs
        [hkstore saveObjects:sampleArray withCompletion:^(BOOL success, NSError *error){
            if(success) {
                //NSLog(@"success");
            }else {
                NSLog(@"%@", error);
            }
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
        HKQuantitySample * calSample = [HKQuantitySample quantitySampleWithType:quantityType quantity:quantity startDate:dateTime endDate:dateTime metadata:metadata];

        // Add sample to array
        [energyArray addObject:calSample];
    }
    // Add to healthkit
    [hkstore saveObjects:energyArray withCompletion:^(BOOL success, NSError *error){
        if(success) {
            //NSLog(@"success");
        }else {
            NSLog(@"%@", error);
        }

    }];
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
        HKQuantitySample * waterSample = [HKQuantitySample quantitySampleWithType:quantityType quantity:quantity startDate:dateTime1 endDate:dateTime2 metadata:metadata];

        if(value != 0){
            [self UpdateSQL:[entry objectForKey:@"value"] type:@"Water" date1:date insertTimestamp:@0 time1:@"12:00:00" time2:@"12:00:00" date2:date];
            [waterArray addObject:waterSample];
        }
    }

    // Add to healthkit
    if([waterArray count] > 0)
    {
        [hkstore saveObjects:waterArray withCompletion:^(BOOL success, NSError *error){
            if(success) {
                //NSLog(@"success");
            }else {
                NSLog(@"%@", error);
            }
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
        NSDate *now = [NSDate date];
        NSNumber *nowEpochSeconds = [NSNumber numberWithInt:[now timeIntervalSince1970]];
        
        [self UpdateSQL:[block2 objectForKey:@"restingHeartRate"] type:@"RestingHR" date1:[block objectForKey:@"dateTime"] insertTimestamp:@0 time1:@"12:00:00" time2:@"12:00:00" date2:[block objectForKey:@"dateTime"]];
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
            //NSLog(@"success");
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
        NSString * dates = AS([block objectForKey:@"dateTime"], @" 12:00:00");
        NSDate * date = [self convertDate:dates];

        HKUnit *floorUnit = [HKUnit unitFromString:@"count"];
        
        //Defined quantity
        HKQuantity *quantity = [HKQuantity quantityWithUnit:floorUnit doubleValue:floors];
        
        NSDate *now = [NSDate date];
        NSNumber *nowEpochSeconds = [NSNumber numberWithInt:[now timeIntervalSince1970]];
        
        // Update
        [self UpdateSQL:[block objectForKey:@"value"] type:@"Floors" date1:[block objectForKey:@"dateTime"] insertTimestamp:@0 time1:@"12:00:00" time2:@"12:00:00" date2:[block objectForKey:@"dateTime"]];
        
        // Create meta indetifier to disable duplication of data
        NSString *identifer = AS(dates,@"Floors");
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

// SQL method to update
- (void) UpdateSQL: (NSString *) value type:(NSString *) entity date1:(NSString *)date1 insertTimestamp:(NSNumber *) timestamp time1:(NSString *) time1 time2:(NSString *) time2 date2:(NSString *) date2
{
    // If date2 and time2 isnt used copy date and time to date2 and time2
    if(([date2  isEqual: @""] || date2 == nil) && ([time2  isEqual: @""] || time2 == nil)){
        date2 = date1;
        time2 = time1;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://apple.rob-balmbra.co.uk/update.php?entity=%@&date=%@&value=%@&uid=%@&timestamp=%@&time=%@&date2=%@&time2=%@", entity, date1, value, self->userid, [timestamp stringValue], time1,date2,time2]];
    [NSData dataWithContentsOfURL:url];
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
        NSString * dates = AS([block objectForKey:@"dateTime"], @" 12:00:00");
        NSDate * date = [self convertDate:dates];
        
        // Get timestamp now
        NSDate *now = [NSDate date];
        NSNumber *nowEpochSeconds = [NSNumber numberWithInt:[now timeIntervalSince1970]];

        // Update
        [self UpdateSQL:[block objectForKey:@"value"] type:@"Steps" date1:[block objectForKey:@"dateTime"] insertTimestamp:@0 time1:@"12:00:00" time2:@"12:00:00" date2:[block objectForKey:@"dateTime"]];

        // Define quantity
        HKQuantity *quantity = [HKQuantity quantityWithUnit:stepUnit doubleValue:steps];
        NSString *identifer = AS(dates,@"Steps");
        
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
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormat setFormatterBehavior:NSDateFormatterBehaviorDefault];
    NSDate *date = [dateFormat dateFromString:Simpledate];
    [dateFormat setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
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
    // TODO - Wrap this method in dispatch_group to avoid function taking too long??!? -maybe, may be too long???
    
    ////////////////////////////////////////////////// Steps /////////////////////////////////////////////////////
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://apple.rob-balmbra.co.uk/query.php?entity=%@&uid=%@", @"Steps", self->userid]];
    NSArray * results = [self GetHistoricData:url];

    // Only parse valid content
    if([results count] > 0){

        // Define type
        HKQuantityType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];

        // Define unit
        HKUnit *stepUnit = [HKUnit unitFromString:@"count"];

        NSMutableArray *stepSamples = [NSMutableArray array];
        
        // Loop over entries
        for(NSDictionary *entry in results){
            double value = [[entry objectForKey:@"value"] doubleValue];
            NSString * time = [entry objectForKey:@"time"];
            NSString * dates = AS(AS([entry objectForKey:@"datetime"],@" "),time);
            NSDate * date = [self convertDate:dates];

            // Define quantity
            HKQuantity *quantity = [HKQuantity quantityWithUnit:stepUnit doubleValue:value];

            // Get metadate for stopping duplication
            NSDictionary * metadata = [self ReturnMetadata:@"Steps" date:dates];
            
            // Create Sample with step value
            HKQuantitySample * stepSample = [HKQuantitySample quantitySampleWithType:stepType quantity:quantity startDate:date endDate:date metadata:metadata];
            
            // Add to sample array
            [stepSamples addObject:stepSample];
            
            // Insert into healthkit and return response error or success
            [hkstore saveObjects:stepSamples withCompletion:^(BOOL success, NSError *error){
                if(success) {
                    //NSLog(@"success");
                }else {
                    NSLog(@"%@", error);
                }
            }];
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
            NSDictionary * metadata = [self ReturnMetadata:@"Asleep" date:[entry objectForKey:@"datetime"]];

            // Create sample
            HKCategorySample * sleepSample = [HKCategorySample categorySampleWithType:sleepType value:HKCategoryValueSleepAnalysisInBed startDate:startDate endDate:endDate metadata:metadata];

            // Add to sample array
            [sleepSamples addObject:sleepSample];
        }

        // Insert into healthkit and return response error or success
        [hkstore saveObjects:sleepSamples withCompletion:^(BOOL success, NSError *error){
            if(success) {
                //NSLog(@"success");
            }else {
                NSLog(@"%@", error);
            }
        }];
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
            NSDictionary * metadata = [self ReturnMetadata:@"Floors" date:dates];

            // Create Sample with step value
            HKQuantitySample * floorSample = [HKQuantitySample quantitySampleWithType:floorType quantity:quantity startDate:date endDate:date metadata:metadata];

            // Add to sample array
            [floorSamples addObject:floorSample];
        }
        
        // Insert into healthkit and return response error or success
        [hkstore saveObjects:floorSamples withCompletion:^(BOOL success, NSError *error){
            if(success) {
                //NSLog(@"success");
            }else {
                NSLog(@"%@", error);
            }
        }];
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
            NSDictionary * metadata = [self ReturnMetadata:@"Weight" date:dates];
            
            // Create Sample with step value
            HKQuantitySample * weightSample = [HKQuantitySample quantitySampleWithType:weightType quantity:quantity startDate:date endDate:date metadata:metadata];
            
            // Add to sample array
            [weightSamples addObject:weightSample];
        }
        
        // Insert into healthkit and return response error or success
        [hkstore saveObjects:weightSamples withCompletion:^(BOOL success, NSError *error){
            if(success) {
                //NSLog(@"success");
            }else {
                NSLog(@"%@", error);
            }
        }];
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
            NSDictionary * metadata = [self ReturnMetadata:@"Bmi" date:dates];

            // Create Sample with step value
            HKQuantitySample * bmiSample = [HKQuantitySample quantitySampleWithType:bmiType quantity:quantity startDate:date endDate:date metadata:metadata];

            // Add to sample array
            [bmiSamples addObject:bmiSample];
        }

        // Insert into healthkit and return response error or success
        [hkstore saveObjects:bmiSamples withCompletion:^(BOOL success, NSError *error){
            if(success) {
                //NSLog(@"success");
            }else {
                NSLog(@"%@", error);
            }
        }];
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
        [manager requestGET:url Token:token success:^(NSDictionary *responseObject) {
           
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

            // Retrieve over
            [self getFitbitURL];
        }else{
            self->resultView.text = @"Too many requests, try again later...";
        }
    });
}

// Pass URL and return json from fitbit API
-(void)getFitbitURL{

    dispatch_group_t group = dispatch_group_create();

    NSMutableArray *URLS = [self generateURLS];
    for (NSMutableArray *entity in URLS){

        if(self->apiNoRequests == 1){
            break;
        }

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

            // Print method to console
            NSLog(@"Running `%@`",type);
            
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
                    NSLog(@"Error - Failed to find method `%@`. %@",methodName, exception);
                }
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
            if([message isEqual: @"Too Many Requests"]){
                NSDate *now = [NSDate date];
                NSInteger nowEpochSeconds = [now timeIntervalSince1970];
                
                NSInteger new_number = nowEpochSeconds - (nowEpochSeconds % 3600);
                self->nearestHour = (new_number + 3600) + 15;

                self->apiNoRequests = 1;
                self->resultView.text = @"Too many requests, try again later...";
            }else{
                self->apiNoRequests = 0;
                self->nearestHour = -1;
            }

            dispatch_group_leave(group);
        }];
    }

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if(self->apiNoRequests == 0){
            self->resultView.text = @"Sync Complete";
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

    // Check if internet available
    BOOL isNetworkAvailable = [self checkNetConnection];
    if (!isNetworkAvailable) {
        [self showAlert:@"Please check your internet connection"];
        return;
    }

    NSDate *now = [NSDate date];
    NSInteger nowEpochSeconds = [now timeIntervalSince1970];

    if(self->nearestHour != -1 && nowEpochSeconds > self->nearestHour)
    {
        self->apiNoRequests = 0;
        self->nearestHour = -1;
    }

    if(self->apiNoRequests == 1){
        self->resultView.text = @"Too many requests, try again later...";
        return;
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
                            [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMassIndex]
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
