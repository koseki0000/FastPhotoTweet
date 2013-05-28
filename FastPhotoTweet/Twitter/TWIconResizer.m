//
//  TWIconResizer.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/08.
//

#import "TWIconResizer.h"

@implementation TWIconResizer

+ (NSString *)iconURL:(NSString *)iconURL iconSize:(IconSize)iconSize {
    
    if ( iconURL == nil ||
        [iconURL isEqualToString:@""] ) {
     
        return @"";
    }
    
    NSString *resizedIconURL = @"";
    NSMutableString *URLSuffix = [[@"" mutableCopy] autorelease];
    
    switch (iconSize) {
        case IconSizeMini:
            [URLSuffix appendString:@"_mini"];
            break;
            
        case IconSizeNormal:
            [URLSuffix appendString:@"_normal"];
            break;
            
        case IconSizeBigger:
            [URLSuffix appendString:@"_bigger"];
            break;
            
        case IconSizeOriginal:
            break;
            
        case IconSizeOriginal96:
            break;
            
        default:
            break;
    }
    
    if ( (iconSize != IconSizeOriginal && iconSize != IconSizeOriginal96) &&
         [URLSuffix isEqualToString:@""] ) {
        
        return @"";
    }
    
    NSString *planeFileName = [iconURL substringWithRange:NSMakeRange(0,
                                                                      [iconURL length] - [[iconURL pathExtension] length])];
    
    if ( [planeFileName hasSuffix:@"_normal."] ) {
        
        planeFileName = [planeFileName substringWithRange:NSMakeRange(0,
                                                                      [planeFileName length] - 8)];
        resizedIconURL = [NSString stringWithFormat:@"%@%@.%@", planeFileName, URLSuffix, [iconURL pathExtension]];
        
    }else if ( [planeFileName hasSuffix:@"_normal"] ) {
        
        planeFileName = [planeFileName substringWithRange:NSMakeRange(0,
                                                                      [planeFileName length] - 7)];
        resizedIconURL = [NSString stringWithFormat:@"%@%@", planeFileName, URLSuffix];
        
    } else {
        
        return iconURL;
    }
    
    return resizedIconURL;
}

@end
