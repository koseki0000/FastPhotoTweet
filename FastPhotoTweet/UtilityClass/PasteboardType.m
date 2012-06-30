//
//  PasteboardType.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/03/01.
//

#import "PasteboardType.h"

@implementation PasteboardType

+ (int)check {
    
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    //NSLog(@"pboard: %@", pboard.pasteboardTypes);

    int pBoardType = -1;
    int i = 0;
    
    for ( NSString *temp in pboard.pasteboardTypes ) {
     
        if ( [[pboard.pasteboardTypes objectAtIndex:i] isEqualToString:@"public.text"] ||
             [[pboard.pasteboardTypes objectAtIndex:i] isEqualToString:@"public.utf8-plain-text"] ||
             [[pboard.pasteboardTypes objectAtIndex:i] isEqualToString:@"public.url"] ) {
            
            //テキストの場合
            return 0;
            
        }else if ( [[pboard.pasteboardTypes objectAtIndex:i] isEqualToString:@"public.jpeg"] ||
                   [[pboard.pasteboardTypes objectAtIndex:i] isEqualToString:@"public.png"] ||
                   [[pboard.pasteboardTypes objectAtIndex:i] isEqualToString:@"public.gif"] ||
                   [[pboard.pasteboardTypes objectAtIndex:i] isEqualToString:@"public.bmp"] ) {
            
            //画像の場合
            return 1;
        }
        
        i++;
    }
        
    return pBoardType;
}

+ (BOOL)isText {
    
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    int i = 0;
    BOOL result = NO;
    
    for ( NSString *temp in pboard.pasteboardTypes ) {
        
        if ( [[pboard.pasteboardTypes objectAtIndex:i] isEqualToString:@"public.text"] ||
             [[pboard.pasteboardTypes objectAtIndex:i] isEqualToString:@"public.utf8-plain-text"] ||
             [[pboard.pasteboardTypes objectAtIndex:i] isEqualToString:@"public.url"] ) {
            
            //テキストの場合
            result = YES;
        }
    }
    
    return result;
}

+ (BOOL)isImage {
    
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    int i = 0;
    BOOL result = NO;
    
    for ( NSString *temp in pboard.pasteboardTypes ) {
        
        if ( [[pboard.pasteboardTypes objectAtIndex:i] isEqualToString:@"public.jpeg"] ||
             [[pboard.pasteboardTypes objectAtIndex:i] isEqualToString:@"public.png"] ||
             [[pboard.pasteboardTypes objectAtIndex:i] isEqualToString:@"public.gif"] ||
             [[pboard.pasteboardTypes objectAtIndex:i] isEqualToString:@"public.bmp"] ) {
            
            //画像の場合
            result = YES;
        }
    }
    
    return result;
}

@end
