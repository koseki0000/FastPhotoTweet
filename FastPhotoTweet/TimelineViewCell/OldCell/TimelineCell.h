//
//  TimelineCell.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/08.
//

#import <UIKit/UIKit.h>
#import "TitleButton.h"

@interface TimelineCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UILabel *infoLabel;
@property (retain, nonatomic) IBOutlet UILabel *mainText;
@property (retain, nonatomic) IBOutlet TitleButton *iconView;

@end