//
//  InputAlertView.m
//

#import "InputAlertView.h"

#define CANCEL_BUTTON 0
#define OK_BUTTON 1

typedef enum {
    TextFieldTypeSingle,
    TextFieldTypeMultiTop,
    TextFieldTypeMultiBottom
}TextFieldType;

@interface InputAlertView ()

- (void)doAction;

@end

@implementation InputAlertView

- (id)initWithTitle:(NSString *)title
           delegate:(id)delegate
  cancelButtonTitle:(NSString *)cancelButtonTitle
    doneButtonTitle:(NSString *)doneButtonTitle
  isMultiInputField:(BOOL)isMultiInputField
         doneAction:(SEL)doneAction {
    
    self = [super initWithTitle:title
                        message:isMultiInputField ? @"\n\n" : @"\n"
                       delegate:self
              cancelButtonTitle:cancelButtonTitle
              otherButtonTitles:doneButtonTitle, nil];
    
    if ( self ) {

        [self setDoneAction:doneAction];
        [self setIsMultiInputField:isMultiInputField];
        [self setTarget:delegate];
        
        if ( isMultiInputField ) {
            
            self.multiTextFieldTop = [[UITextField alloc] initWithFrame:CGRectMake(12.0f,
                                                                                   40.0f,
                                                                                   260.0f,
                                                                                   25.0f)];
            [self.multiTextFieldTop setBackgroundColor:[UIColor whiteColor]];
            [self.multiTextFieldTop setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [self.multiTextFieldTop setDelegate:self];
            [self.multiTextFieldTop setText:@""];
            [self.multiTextFieldTop setTag:TextFieldTypeMultiTop];
            [self addSubview:self.multiTextFieldTop];
            
            self.multiTextFieldBottom = [[UITextField alloc] initWithFrame:CGRectMake(12.0f,
                                                                                      CGRectGetMaxY(self.multiTextFieldTop.frame) + 2.0f,
                                                                                      260.0f,
                                                                                      25.0f)];
            [self.multiTextFieldBottom setBackgroundColor:[UIColor whiteColor]];
            [self.multiTextFieldBottom setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [self.multiTextFieldBottom setDelegate:self];
            [self.multiTextFieldBottom setText:@""];
            [self.multiTextFieldBottom setTag:TextFieldTypeMultiBottom];
            [self addSubview:self.multiTextFieldBottom];
            
        }else {
            
            self.singleTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0f,
                                                                                 40.0f,
                                                                                 260.0f,
                                                                                 25.0f)];
            [self.singleTextField setBackgroundColor:[UIColor whiteColor]];
            [self.singleTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [self.singleTextField setDelegate:self];
            [self.singleTextField setText:@""];
            [self.multiTextFieldTop setTag:TextFieldTypeSingle];
            [self addSubview:self.singleTextField];
        }
    }
    
    return self;
}

- (void)doAction {
    
    [self.singleTextField resignFirstResponder];
    [self.multiTextFieldTop resignFirstResponder];
    [self.multiTextFieldBottom resignFirstResponder];
    
    if ( self.isMultiInputField ) {
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.target performSelector:self.doneAction
                            withObject:self.multiTextFieldTop.text
                            withObject:self.multiTextFieldBottom.text];
#pragma clang diagnostic pop
        
    }else {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.target performSelector:self.doneAction
                            withObject:self.singleTextField.text];
#pragma clang diagnostic pop
    }
}

- (void)show {
    
    [super show];
    
    if ( self.isMultiInputField ) {
        
        [self.multiTextFieldTop becomeFirstResponder];
        
    }else {
        
        [self.singleTextField becomeFirstResponder];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ( buttonIndex == OK_BUTTON ) {
        
        [self doAction];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ( textField.tag == TextFieldTypeMultiTop ) {
        
        [self.multiTextFieldBottom becomeFirstResponder];
        return NO;
        
    }else {
     
        [self doAction];
        [self dismissWithClickedButtonIndex:CANCEL_BUTTON
                                   animated:YES];
        return YES;
    }
}

@end
