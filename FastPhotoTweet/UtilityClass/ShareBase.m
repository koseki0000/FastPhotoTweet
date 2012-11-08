//
//  SharedObject.m
//

#import "ShareBase.h"

@implementation ShareBase

static ShareBase *sharedObject = nil;

+ (id)manager {
    
    if ( sharedObject == nil ) {
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            [[self alloc] init];
        });
    }
    
    return sharedObject;
}

+ (id)images {
    
    return sharedObject.images;
}

+ (id)allocWithZone:(NSZone *)zone {
    
    if ( sharedObject == nil ) {
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            sharedObject = [super allocWithZone:zone];
            sharedObject.images = [NSMutableDictionary dictionary];
        });
        
        return sharedObject;
    }
    
    return nil;
}

- (id)copyWithZone:(NSZone*)zone {
    
    return self;
}

- (id)retain {
    
    return self;
}

- (unsigned)retainCount {
    
    return UINT_MAX;
}

- (oneway void)release {
    
}

- (id)autorelease {
    
    return self;
}

- (void)dealloc {
    
    [self setImages:nil];
    
    [super dealloc];
}

@end
