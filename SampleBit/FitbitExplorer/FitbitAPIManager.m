//
//  FitbitAPIManager.m
//  SampleBit
//
//  Created by Deepak on 1/18/17.
//  Copyright © 2017 InsanelyDeepak. All rights reserved.
//

#import "FitbitAPIManager.h"
#import "../XMLReader/XMLReader.h"

#define AS(A,B)    [(A) stringByAppendingString:(B)]

@implementation FitbitAPIManager {
    NSURLSession *session;
}
+ (instancetype)sharedManager {
    static FitbitAPIManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[FitbitAPIManager alloc] init];
    });
    
    return _sharedManager;
}

-(void)requestGET:(NSString *)strURL xml:(BOOL)xml Token:(NSString *)token success:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure {
    
    BOOL isNetworkAvailable = [self checkNetConnection];
    
    if (!isNetworkAvailable) {
        NSLog(@"No connection");
        [self showAlert:@"Please check your internet connection"];
        return;
    }else{
 
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",token] forHTTPHeaderField:@"Authorization"];
        
        if(xml){
            // Content xml
            manager.responseSerializer = [AFHTTPResponseSerializer new];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/vnd.garmin.tcx+xml", nil];
        }else{
            // Content json
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
        }
        
        [manager GET:strURL parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if([responseObject isKindOfClass:[NSDictionary class]]) {
                // Return json
                if(success) {
                    success(responseObject);
                }
            }else{
                // Return xml to nsdictionary
                if(success){
                    NSString* responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                    NSDictionary * XMLDictionary = [XMLReader dictionaryForXMLString:responseStr error:nil];
                    success(XMLDictionary);
                }
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            //NSLog(@"%@", error);
            if(failure) {
                failure(error);
            }
        }];
    }
}

-(void)requestPOST:(NSString *)strURL Parameter:(NSDictionary *)param Token:(NSString *)token success:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure {
    
    BOOL isNetworkAvailable = [self checkNetConnection];
    
    if (!isNetworkAvailable) {
        [self showAlert:@"Please check your internet connection"];
    }
    else {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",token] forHTTPHeaderField:@"Authorization"];
        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        
        [manager POST:strURL parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if([responseObject isKindOfClass:[NSDictionary class]]) {
                if(success) {
                    success(responseObject);
                }
            }else{
                //NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
                //if(success) {
                //    success(response);
                //}
            }

        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if(failure) {
                failure(error);
            }
        }];
        
    }
}
-(void)showAlert :(NSString *)message{
    UIWindow* window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.rootViewController = [UIViewController new];
    window.windowLevel = UIWindowLevelAlert + 1;
    
    UIAlertController* alertView = [UIAlertController alertControllerWithTitle:@"Info!" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alertView addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        window.hidden = YES;
    }]];
    
    [window makeKeyAndVisible];
    [window.rootViewController presentViewController:alertView animated:YES completion:nil];
}
//-----------------------------------------------------
//                 Method : Reachability
//-----------------------------------------------------

-(BOOL)checkNetConnection
{
    Reachability * reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus] ;
    
    if(internetStatus == NotReachable)
    {
        NSLog(@"Network is not reachable");
        return NO;
    }
    else {
        // NSLog(@"Network is reachable");
        return YES;
    }
}
//-----------------------------------------------------
//-----------------------------------------------------

@end
