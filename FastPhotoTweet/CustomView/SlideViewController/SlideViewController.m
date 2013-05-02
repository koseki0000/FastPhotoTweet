//
//  SlideViewController.m
//

#import "SlideViewController.h"

@implementation SlideViewController

- (id)init {
    
    self = [super init];
    
    if ( self ) {
        
        [self setDefault];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if ( self ) {
        
        [self setDefault];
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self ) {
        
        [self setDefault];
    }
    
    return self;
}

- (void)setDefault {

    _viewDefaultRect = self.view.frame;
    int margine = _viewDefaultRect.size.width / 6;
    int newX = _viewDefaultRect.origin.x + _viewDefaultRect.size.width - margine;
    int newY = _viewDefaultRect.origin.y;
    int newW = _viewDefaultRect.size.width;
    int newH = _viewDefaultRect.size.height;
    
    _viewMenuRect = CGRectMake(newX,
                               newY,
                               newW,
                               newH);
    _moveMode = NO;
    _showMenu = NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if ( _moveMode || !_touchSlideEnable ) return;
    
    _moveMode = YES;
    CGPoint touchPoint = [[touches anyObject] locationInView:self.view];
    _viewStartX = touchPoint.x;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if ( _moveMode || !_touchSlideEnable ) return;
    
    CGPoint touchPoint = [[touches anyObject] locationInView:self.view];
    float diff = _viewStartX - touchPoint.x;
    float viewNewX = self.view.frame.origin.x - diff;
    
    if ((!_showMenu && viewNewX  < 0) ||
        ( _showMenu && viewNewX  > 267) ||
        self.view.frame.origin.x < 0 ) return;
    
    CGRect newRect = CGRectMake(viewNewX,
                                0,
                                _viewDefaultRect.size.width,
                                _viewDefaultRect.size.height);
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                         self.view.frame = newRect;
                     }
     ];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if ( _moveMode || !_touchSlideEnable ) return;
    
    CGPoint touchPoint = [[touches anyObject] locationInView:self.view];
    _moveMode = NO;
    
    if ( _showMenu && _viewStartX == touchPoint.x ) {
        
        [self setDefaultViewPosition];
        
    }else if ( self.view.frame.origin.x > 160 ) {
        
        [self setMenuViewPosition];
        
    }else {
        
        [self setDefaultViewPosition];
    }
}

- (void)setDefaultViewPosition {
    
    [UIView animateWithDuration:0.3
                     animations:^ {
                         
                         self.view.frame = _viewDefaultRect;
                     }
     
                     completion:^ (BOOL finished) {
                         
                         _showMenu = NO;
                     }
     ];
}

- (void)setMenuViewPosition {
    
    _showMenu = YES;
    
    [UIView animateWithDuration:0.3
                     animations:^ {
                         
                         self.view.frame = _viewMenuRect;
                     }
     ];
}

@end
