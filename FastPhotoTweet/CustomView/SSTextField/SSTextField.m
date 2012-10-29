//
//  SSTextField.m
//

#import "SSTextField.h"

@implementation SSTextField

- (id)init {
    
    self = [super init];
    
    if ( self ) {
        
        [self addGesture];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if ( self ) {
        
        [self addGesture];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if ( self ) {
        
        [self addGesture];
    }
    
    return self;
}

- (void)addGesture {
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeShiftRight:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipeRight];
    [swipeRight release];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeShiftLeft:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swipeLeft];
    [swipeLeft release];
}

- (void)swipeShiftRight:(UISwipeGestureRecognizer *)sender {
    
    if ( ![[NSUserDefaults standardUserDefaults] boolForKey:@"SwipeShiftCaret"] ) return;
    
    UITextRange *currentRange = self.selectedTextRange;
    
    if ( [currentRange.end isEqual:self.endOfDocument] ) return;
    
    UITextPosition *newPosition = [self positionFromPosition:currentRange.end offset:1];
    
    UITextRange *newRange;
    
    if ( [currentRange isEmpty] ) {
        
        newRange = [self textRangeFromPosition:newPosition
                                    toPosition:newPosition];
        
    }else{
        
        newRange = [self textRangeFromPosition:newPosition
                                    toPosition:currentRange.end];
    }
    
    self.selectedTextRange = newRange;
    
}

- (void)swipeShiftLeft:(UISwipeGestureRecognizer *)sender {
    
    if ( ![[NSUserDefaults standardUserDefaults] boolForKey:@"SwipeShiftCaret"] ) return;
    
    UITextRange *currentRange = self.selectedTextRange;
    
    if ( [currentRange.start isEqual:self.beginningOfDocument] ) return;
    
    UITextPosition *newPosition = [self positionFromPosition:currentRange.start offset:-1];
    
    UITextRange *newRange;
    if ( [currentRange isEmpty] ) {
        
        newRange = [self textRangeFromPosition:newPosition
                                    toPosition:newPosition];
        
    }else {
        
        newRange = [self textRangeFromPosition:newPosition
                                    toPosition:currentRange.end];
    }
    
    self.selectedTextRange = newRange;
}

@end
