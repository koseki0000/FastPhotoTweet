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
    NSLog(@"pboard: %@", pboard.pasteboardTypes);
    
    int pBoardType = 0;
    
    if ( [[pboard.pasteboardTypes objectAtIndex:0] isEqualToString:@"public.text"] ) {
        
        //テキストの場合
        pBoardType = 0;
        
    }else if ( [[pboard.pasteboardTypes objectAtIndex:0] isEqualToString:@"public.jpeg"] ||
               [[pboard.pasteboardTypes objectAtIndex:0] isEqualToString:@"public.png"] ||
               [[pboard.pasteboardTypes objectAtIndex:0] isEqualToString:@"public.gif"] ||
               [[pboard.pasteboardTypes objectAtIndex:0] isEqualToString:@"public.bmp"] ) {
        
        //画像の場合
        pBoardType = 1;
        
    }else {
        
        //得体の知れない物
        ShowAlert *alert = [[ShowAlert alloc] init];
        [alert error:@"ペーストボードの中身がテキストか画像以外です。"];
        
        return -1;
    }
    
    return pBoardType;
}

@end
