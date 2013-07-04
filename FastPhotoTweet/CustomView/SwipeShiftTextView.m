//
//  SwipeShiftTextView.m
//

#import "SwipeShiftTextView.h"
#import "AppDelegate.h"

@interface SwipeShiftTextView ()

- (void)addGestures;
- (void)swipe:(UISwipeGestureRecognizer *)sender;

@end

@implementation SwipeShiftTextView

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
    
    if ( [self isEditable] ) {
        
        NSInteger offset = 0;
        NSInteger location = 0;
        
        if ( sender.direction == UISwipeGestureRecognizerDirectionLeft ) {
            
            if ( [self.text isEqualToString:@""] &&
                 self.tag == 1000 ) {
                
                [[(AppDelegate *)[[UIApplication sharedApplication] delegate] tabBarController] setSelectedIndex:1];
                return;
            }
            
            if ( ![USER_DEFAULTS boolForKey:@"SwipeShiftCaret"] ) {
                
                return;
            }
            
            if ( self.selectedRange.location != 0 ) {
                
                return;
            }
            
            offset = -1;
            location = self.selectedRange.location + offset;
            
        } else if ( sender.direction == UISwipeGestureRecognizerDirectionRight ) {
            
            if ( ![USER_DEFAULTS boolForKey:@"SwipeShiftCaret"] ) {
                
                return;
            }
            
            offset = 1;
            location = self.selectedRange.location + offset;
            
            if ( location <= [self.text length] ) {
                
                return;
            }
        
        } else {
            
            return;
        }
        
        [self setSelectedRange:NSMakeRange(location,
                                           0)];
    }
}

@end
