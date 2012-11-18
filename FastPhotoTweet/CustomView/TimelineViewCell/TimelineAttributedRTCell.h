//
//  TimelineAttributedRTCell.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/11/18.
//
//

#import <UIKit/UITableViewCell.h>
#import <QuartzCore/QuartzCore.h>
#import "OHAttributedLabel.h"
#import "TitleButton.h"
#import "NSAttributedString+Attributes.h"
#import "UIViewSubViewRemover.h"

@interface TimelineAttributedRTCell : UITableViewCell

@property (strong, nonatomic) UILabel *infoLabel;
@property (strong, nonatomic) OHAttributedLabel *mainLabel;
@property (strong, nonatomic) TitleButton *iconView;

- (void)setProperties;

@end