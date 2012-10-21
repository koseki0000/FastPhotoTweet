//
//  TimelineAttributedCell.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/10/19.
//
//

#import <UIKit/UITableViewCell.h>
#import "OHAttributedLabel.h"
#import "TitleButton.h"
#import "NSAttributedString+Attributes.h"
#import "UIViewSubViewRemover.h"

@interface TimelineAttributedCell : UITableViewCell <OHAttributedLabelDelegate>

@property (retain, nonatomic) OHAttributedLabel *infoLabel;
@property (retain, nonatomic) OHAttributedLabel *mainLabel;
@property (retain, nonatomic) TitleButton *iconView;

@end
