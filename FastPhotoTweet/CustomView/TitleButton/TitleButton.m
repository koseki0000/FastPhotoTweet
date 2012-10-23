//
//  TitleButton.m
//  FastPhotoTweet
//
//  Created by peace3884 on 12/10/18.
//
//

#import "TitleButton.h"

@implementation TitleButton
@synthesize buttonTitle;

- (void)dealloc {
    
    [self setButtonTitle:nil];
    
    [super dealloc];
}

@end
