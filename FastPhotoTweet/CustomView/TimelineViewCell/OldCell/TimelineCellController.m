//
//  TimelineCellController.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/08.
//

#import "TimelineCellController.h"

@implementation TimelineCellController
@synthesize cell;

- (void)dealloc {

    //NSLog(@"TimelineCellController dealloc");
    
    [cell removeFromSuperview];
    cell = nil;
    
	[super dealloc];
}

@end