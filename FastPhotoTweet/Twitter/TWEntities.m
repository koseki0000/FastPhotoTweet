//
//  TWEntities.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/25.
//

#import "TWEntities.h"

@implementation TWEntities

//TwitterのレスポンスからJSONframeworkで生成されたDictionaryを渡すとt.coを展開した本文を返す
+ (NSString *)replace:(NSDictionary *)dictionary {
    
    NSMutableString *text = nil;
    
    if ( [dictionary objectForKey:@"event"] == nil ) {
        
        text = [NSMutableString stringWithString:[dictionary objectForKey:@"text"]];
        
    }else {
    
        text = [NSMutableString stringWithString:[[dictionary objectForKey:@"target_object"] objectForKey:@"text"]];
    }
    
    @try {
        
        if ( [[dictionary objectForKey:@"entities"] objectForKey:@"urls"] == nil ) return text;
        
        NSArray *urls = [[dictionary objectForKey:@"entities"] objectForKey:@"urls"];
        
        for ( NSDictionary *url in urls ) {
            
            NSString *tcoURL = [url objectForKey:@"url"];
            NSString *expandedURL = [url objectForKey:@"expanded_url"];
            
            [text replaceOccurrencesOfString:tcoURL 
                                  withString:expandedURL 
                                     options:0 
                                       range:NSMakeRange( 0, text.length )];
        }
        
        [text replaceOccurrencesOfString:@"&gt;" withString:@">" options:0 range:NSMakeRange(0, [text length] )];
        [text replaceOccurrencesOfString:@"&lt;" withString:@"<" options:0 range:NSMakeRange(0, [text length] )];
        [text replaceOccurrencesOfString:@"&amp;" withString:@"&" options:0 range:NSMakeRange(0, [text length] )];
        
    }@catch ( NSException *e ) {
        
        return [dictionary objectForKey:@"text"];
    }
    
    return text;
}

@end
