//
//  TimelineCell.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 11/07/16.
//

#import "TableViewCell.h"

@implementation TableViewCell
@synthesize numberLabel;
@synthesize textLabel;

- (void)dealloc {
    
    [numberLabel removeFromSuperview];
    numberLabel = nil;
    [textLabel removeFromSuperview];
    textLabel = nil;
}

@end
