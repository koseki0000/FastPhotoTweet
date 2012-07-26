//
//  TWAccountSelectView.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/23.
//

#import <UIKit/UIKit.h>

@interface TWAccountSelectView : UIView

@property (retain, nonatomic) IBOutlet UIView *view;
@property (retain, nonatomic) IBOutlet UIPickerView *picker;
@property (retain, nonatomic) IBOutlet UIToolbar *bar;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *space;

@end
