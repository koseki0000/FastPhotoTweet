//
//  SpecialThanksViewController.h
//  FastPhotoTweet
//
//  Created by m.s.s02968 on 12/11/04.
//
//

#import <UIKit/UIKit.h>

@interface SpecialThanksViewController : UIViewController

@property (retain, nonatomic) IBOutlet UITextView *mainText;
@property (retain, nonatomic) IBOutlet UINavigationBar *topBar;
@property (retain, nonatomic) IBOutlet UINavigationItem *backButton;

- (IBAction)pushBackButton:(id)sender;

@end
