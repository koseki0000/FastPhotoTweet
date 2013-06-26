//
//  TableViewCell.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 11/07/16.
//

#import "TableViewCell.h"

@implementation TableViewCell

- (void)dealloc {

    [self.numberLabel removeFromSuperview];
    self.numberLabel = nil;
    [self.textLabel removeFromSuperview];
    self.textLabel = nil;
}

@end
