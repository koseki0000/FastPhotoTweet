//
//  InternetConnection.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/09/10.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "ShowAlert.h"

@interface InternetConnection : NSObject

+ (BOOL)mobile;
+ (BOOL)wifi;
+ (BOOL)enable;
+ (BOOL)disable;

@end
