//
//  SlideViewController.h
//

#import <UIKit/UIKit.h>

@interface SlideViewController : UIViewController

@property CGRect viewDefaultRect;
@property CGRect viewMenuRect;
@property float viewStartX;
@property BOOL moveMode;
@property BOOL showMenu;
@property BOOL touchSlideEnable;

- (void)setDefault;
- (void)setDefaultViewPosition;
- (void)setMenuViewPosition;

@end
