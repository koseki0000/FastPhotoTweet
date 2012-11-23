//
//  TitleButton.m
//  FastPhotoTweet
//
//  Created by peace3884 on 12/10/18.
//
//

#import "TitleButton.h"

@implementation TitleButton

- (void)dealloc {
    
    [_buttonTitle release];
    _buttonTitle = nil;
    [super dealloc];
}

@end
