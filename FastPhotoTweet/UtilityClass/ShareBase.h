//
//  SharedObject.h
//

#import <Foundation/Foundation.h>

@interface ShareBase : NSObject

@property (retain, readwrite) NSMutableDictionary *images;

+ (id)manager;
+ (id)images;

@end
