//
//  NSDictionary+XPath.m
//  FastPhotoTweet
//
//  Created by @peace3884 12/11/02.
//

#import "NSDictionary+XPath.h"

@implementation NSDictionary (XPath)

- (id)objectForXPath:(NSString *)xpath separator:(NSString *)separator {
    
    if ( [self isEmpty] ||
         [xpath isEmpty] ||
         [separator isEmpty] ) return self;
    
    while ( [xpath hasPrefix:separator] ) {
        
        xpath = [xpath substringFromIndex:1];
    }
    
    NSMutableArray *separatedXPath = [[[xpath componentsSeparatedByString:separator] mutableCopy] autorelease];
    id object = nil;
    
    if ( [separatedXPath isNotEmpty] ) {
        
        object = self[separatedXPath[0]];
        [separatedXPath removeObjectAtIndex:0];
        
        if ( [separatedXPath isNotEmpty] ) {
        
            NSInteger count = 0;
            for ( NSString *path in separatedXPath ) {
                
                if ( [object isKindOfClass:[NSDictionary class]] ) {
                    
                    NSDictionary *dicObject = (NSDictionary *)object;
                    if ( [dicObject[path] isNotEmpty] ) {
                        
                        if ( count == [separatedXPath count] - 1 ) {
                        
                            object = dicObject[path];
                        }
                    
                    } else {
                        
                        break;
                    }
                    
                }else if ( [object isKindOfClass:[NSArray class]] ) {
                    
                    NSInteger indexPath = [path integerValue];
                    NSArray *arrayObject = (NSArray *)object;
                    if ( [arrayObject isNotEmpty] ) {
                    
                        if ( [arrayObject count] >= indexPath ) {
                            
                            if ( count == [separatedXPath count] - 1 ) {
                                
                                object = arrayObject[indexPath];
                            }
                        
                        } else {
                            
                            break;
                        }
                        
                    } else {
                        
                        break;
                    }
                    
                }else if ( [object isKindOfClass:[NSString class]] ||
                           [object isKindOfClass:[NSNumber class]] ) {
                    
                    return object;
                    
                } else {
                    
                    break;
                }
                
                count++;
            }
            
            if ( count != [separatedXPath count] ) object = nil;
        }
    }
    
    return object;
}

- (id)objectForXPath:(NSString *)xpath {
    
    return [self objectForXPath:xpath
                      separator:@"/"];
}

@end
