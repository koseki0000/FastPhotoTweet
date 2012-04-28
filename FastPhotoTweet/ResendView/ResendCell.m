//
//  ResendCell.m
//  FastPhotoTweet
//
//  Created by Yuki Higurashi on 12/04/28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ResendCell.h"

@implementation ResendCell
@synthesize imageView;
@synthesize textLabel;

- (void)dealloc {
    
    [imageView release];
    [textLabel release];
    [super dealloc];
}

@end
