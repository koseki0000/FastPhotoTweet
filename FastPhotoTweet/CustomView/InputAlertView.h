//
//  InputAlertView.h
//

#import <UIKit/UIKit.h>

@interface InputAlertView : UIAlertView <UIAlertViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) UITextField *singleTextField;

@property (strong, nonatomic) UITextField *multiTextFieldTop;
@property (strong, nonatomic) UITextField *multiTextFieldBottom;

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
