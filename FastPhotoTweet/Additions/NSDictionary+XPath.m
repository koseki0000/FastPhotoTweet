//
//  NSDictionary+XPath.m
//  FastPhotoTweet
//
//  Created by @peace3884 12/11/02.
//

#import "NSDictionary+XPath.h"

@implementation NSDictionary (XPath)

- (id)objectForXPath:(NSString *)xpath separator:(NSString *)separator {
    
    if ( [self isEmpty] || [xpath isEmpty] || [separator isEmpty] ) return self;
    
    while ( [xpath hasPrefix:separator] ) {
        
        xpath = [xpath substringFromIndex:1];
    }
    
    NSMutableArray *separatedXPath = [[xpath componentsSeparatedByString:separator] mutableCopy];
    id object = nil;
    
    if ( [separatedXPath isNotEmpty] ) {
        
        object = [self objectForKey:[separatedXPath objectAtIndex:0]];
        [separatedXPath removeObjectAtIndex:0];
        
        if ( [separatedXPath isNotEmpty] ) {
        
            int count = 0;
            for ( NSString *path in separatedXPath ) {
                
                if ( [object isKindOfClass:[NSDictionary class]] ||
                     [object isKindOfClass:[NSMutableDictionary class]] ) {
                    
                    if ( [[object objectForKey:path] isNotEmpty] ) {
                        
                        object = [object objectForKey:path];
                        
                    }else {
                        
                        break;
                    }
                    
                }else if ( [object isKindOfClass:[NSArray class]] ||
                           [object isKindOfClass:[NSMutableArray class]] ) {
                    
                    int indexPath = [path intValue];
                    
                    if ( [(NSArray *)object isNotEmpty] ) {
                    
                        if ( ((NSArray *)object).count >= indexPath ) {
                            
                            object = [object objectAtIndex:indexPath];
                            
                        }else {
                            
                            break;
                        }
                        
                    }else {
                        
                        break;
                    }
                    
                }else {
                    
                    break;
                }
                
                count++;
            }
            
            if ( count != separatedXPath.count ) object = nil;
        }
    }
    
    [separatedXPath release];
    
    return object;
}

- (id)objectForXPath:(NSString *)xpath {
    
    return [self objectForXPath:xpath separator:@"/"];
}

@end
