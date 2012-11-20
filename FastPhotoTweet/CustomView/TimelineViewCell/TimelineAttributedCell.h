//
//  TimelineAttributedCell.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/10/19.
//
//

#import <UIKit/UITableViewCell.h>
#import <QuartzCore/QuartzCore.h>
#import "OHAttributedLabel.h"
#import "TitleButton.h"
#import "NSAttributedString+Attributes.h"
#import "UIViewSubViewRemover.h"

@interface TimelineAttributedCell : UITableViewCell

@property (strong, nonatomic) UILabel *infoLabel;
@property (strong, nonatomic) OHAttributedLabel *mainLabel;
@property (strong, nonatomic) TitleButton *iconView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier forWidth:(CGFloat)width;
- (void)setProperties:(CGFloat)width;

@end