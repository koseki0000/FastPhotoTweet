//
//  TTDefaultStyleSheetAdditions.m
//  FastPhotoTweet
//
//  Created by Yuki Higurashi on 12/10/15.
//
//

#import "TTDefaultStyleSheetAdditions.h"

@implementation TTDefaultStyleSheet (TimelineUtil)

- (TTStyle *)fontSize12 {
    
    return [TTTextStyle styleWithFont:[UIFont systemFontOfSize:12] next:nil];
}

@end
