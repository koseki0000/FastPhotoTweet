//
//  TWIconBigger.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/08.
//

#import "TWIconBigger.h"

@implementation TWIconBigger

+ (NSString *)normal:(NSString *)normalUrl {
    
    if ( normalUrl == nil || [normalUrl isEqualToString:@""] ) return @"";
    
    NSString *biggerUrl = nil;
    
    @try {
        
        NSString *planeFileName = [normalUrl substringWithRange:NSMakeRange( 0, normalUrl.length - [normalUrl pathExtension].length )];
        
        if ( [planeFileName hasSuffix:@"_normal."] ) {
            
            planeFileName = [planeFileName substringWithRange:NSMakeRange(0, planeFileName.length - 8)];
            biggerUrl = [NSString stringWithFormat:@"%@_bigger.%@", planeFileName, [normalUrl pathExtension]];
            
        }else if ( [planeFileName hasSuffix:@"_normal"] ) {
            
            planeFileName = [planeFileName substringWithRange:NSMakeRange(0, planeFileName.length - 7)];
            biggerUrl = [NSString stringWithFormat:@"%@_bigger", planeFileName];
            
        }else {
            
            return normalUrl;
        }
        
        //NSLog(@"biggerUrl: %@", biggerUrl);
        
    }@catch ( NSException *e ) {
        
        return normalUrl;
    }
    
    return biggerUrl;
}

@end
