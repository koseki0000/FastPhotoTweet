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

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if ( self ) {
        
        [self.titleLabel removeFromSuperview];
        [self.imageView removeFromSuperview];
    }
    
    return self;
}

- (void)dealloc {
    
    [buttonTitle release];
    
    [super dealloc];
}

@end
