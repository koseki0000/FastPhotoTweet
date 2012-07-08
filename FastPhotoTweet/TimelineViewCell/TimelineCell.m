//
//  TimelineCell.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/08.
//

#import "TimelineCell.h"

@implementation TimelineCell
@synthesize infoLabel;
@synthesize textLabel;
@synthesize iconView;

- (void)dealloc {

    [infoLabel release];
	[textLabel release];
    [iconView release];
    [super dealloc];
}

@end
