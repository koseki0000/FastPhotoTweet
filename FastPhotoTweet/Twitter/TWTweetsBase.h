//
//  TWTweetsBase.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/10/27.
//
//

#import <Foundation/Foundation.h>
#import "TWAccounts.h"

@interface TWTweetsBase : NSObject

@property (retain, nonatomic) NSMutableDictionary *timelines;

+ (TWTweetsBase *)manager;

@end
