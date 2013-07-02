//
//  SwipeShiftTextField.m
//

#import "SwipeShiftTextField.h"

@interface SwipeShiftTextField ()

- (void)addGestures;
- (void)swipe:(UISwipeGestureRecognizer *)sender;

@end

@implementation SwipeShiftTextField

- (id)init {
    
    self = [super init];
    
    if ( self ) {
        
        [self addGestures];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if ( self ) {
        
        [self addGestures];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if ( self ) {
        
        [self addGestures];
    }
    
    return self;
}

- (void)addGestures {
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(swipe:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(swipe:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self addGestureRecognizer:swipeLeft];
}

- (void)swipe:(UISwipeGestureRecognizer *)sender {
    
    if ( ![USER_DEFAULTS boolForKey:@"SwipeShiftCaret"] ) {
        
        return;
    }
    
    UITextRange *currentRange = self.selectedTextRange;
    NSInteger offset = 0;
    UITextPosition *fromPosition = nil;
    
    if ( sender.direction == UISwipeGestureRecognizerDirectionLeft ) {
        
        if ( [currentRange.start isEqual:self.beginningOfDocument] ) {
         
            return;
        }
        
        offset = -1;
        fromPosition = currentRange.start;
        
    } else if ( sender.direction == UISwipeGestureRecognizerDirectionRight ) {
        
        if ( [currentRange.end isEqual:self.endOfDocument] ) {
         
            return;
        }
        
        offset = 1;
        fromPosition = currentRange.end;
        
    } else {
        
        return;
    }
    
    UITextPosition *newPosition = [self positionFromPosition:fromPosition
                                                      offset:offset];
    
    UITextRange *newRange = nil;
    if ( [currentRange isEmpty] ) {
        
        newRange = [self textRangeFromPosition:newPosition
                                    toPosition:newPosition];
        
    } else {
        
        newRange = [self textRangeFromPosition:newPosition
                                    toPosition:currentRange.end];
    }
    
    [self setSelectedTextRange:newRange];
}

@end
