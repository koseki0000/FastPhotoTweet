//
//  InputAlertView.h
//

#import <UIKit/UIKit.h>
#import "SwipeShiftTextField.h"

@interface InputAlertView : UIAlertView <UIAlertViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) SwipeShiftTextField *singleTextField;

@property (strong, nonatomic) SwipeShiftTextField *multiTextFieldTop;
@property (strong, nonatomic) SwipeShiftTextField *multiTextFieldBottom;

@property (nonatomic) SEL doneAction;
@property (nonatomic) BOOL isMultiInputField;
@property (weak, nonatomic) id target;

- (id)initWithTitle:(NSString *)title
           delegate:(id)delegate
  cancelButtonTitle:(NSString *)cancelButtonTitle
    doneButtonTitle:(NSString *)doneButtonTitle
  isMultiInputField:(BOOL)isMultiInputField
         doneAction:(SEL)doneAction;

@end
