//
//  NSDictionary+XPath.h
//  FastPhotoTweet
//
//  Created by @peace3884 12/11/02.
//

#import <Foundation/Foundation.h>
#import "NSObject+EmptyCheck.h"

@interface NSDictionary (XPath)

- (id)objectForXPath:(NSString *)xpath separator:(NSString *)separator;
- (id)objectForXPath:(NSString *)xpath;

@end
