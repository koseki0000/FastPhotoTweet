//
//  InternetConnection.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/09/10.
//

#import "InternetConnection.h"

@implementation InternetConnection

//携帯回線で接続されているか
+ (BOOL)mobile {
    
    BOOL result = NO;
    
    if ( [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWWAN ) {
        
        result = YES;
        
    }else {
        
        [ShowAlert error:@"モバイル回線に接続されていません。"];
    }
    
    return result;
}

//Wi-Fiで接続されているか
+ (BOOL)wifi {
    
    BOOL result = NO;
    
    if ( [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWiFi ) {
        
        result = YES;
        
    }else {
        
        [ShowAlert error:@"Wi-Fiに接続されていません。"];
    }
    
    return result;
}

//モバイル回線かWi-Fiで接続されているか
+ (BOOL)enable {
    
    BOOL result = NO;
    
    if ( [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable ) {
        
        result = YES;
        
    }else {
        
        [ShowAlert error:@"インターネットに接続されていません。"];
        
        //オフラインであることを通知する
        NSNotification *notification =[NSNotification notificationWithName:@"Offline"
                                                                    object:self
                                                                  userInfo:nil];
        
        //通知を実行
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        
    }
    
    return result;
}

+ (BOOL)disable {
    
    BOOL result = NO;
    
    if ( [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable ) {
        
        result = YES;
    }
    
    return result;
}

@end
