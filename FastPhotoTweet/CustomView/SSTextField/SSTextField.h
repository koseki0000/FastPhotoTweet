//
//  SSTextField.h
//

#import <UIKit/UIKit.h>

@interface SSTextField : UITextField

- (void)addGesture;
- (void)swipeShiftRight:(UISwipeGestureRecognizer *)sender;
- (void)swipeShiftLeft:(UISwipeGestureRecognizer *)sender;

@end
