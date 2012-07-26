//
//  TWAccountSelectView.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/23.
//

#import "TWAccountSelectView.h"

@implementation TWAccountSelectView
@synthesize view;
@synthesize picker;
@synthesize bar;
@synthesize cancelButton;
@synthesize doneButton;
@synthesize space;

-(id)init{
    
    self = [super init];
    
    if ( self != nil ) {
        
        [[NSBundle mainBundle] loadNibNamed:@"TWAccountSelectView" owner:self options:nil];
    }
    
    return self;
}

- (void)viewDidUnload {
    
    [self setView:nil];
    [self setPicker:nil];
    [self setBar:nil];
    [self setCancelButton:nil];
    [self setDoneButton:nil];
    [self setSpace:nil];
}

- (void)dealloc {
    
    [view release];
    [picker release];
    [bar release];
    [cancelButton release];
    [doneButton release];
    [space release];
    [super dealloc];
}

@end
