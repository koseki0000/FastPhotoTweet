//
//  TimelineAttributedCell.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/10/19.
//
//

#import <UIKit/UITableViewCell.h>
#import "OHAttributedLabel.h"
#import "IconButton.h"

@interface TimelineAttributedCell : UITableViewCell

@property (strong, nonatomic) UILabel *infoLabel;
@property (strong, nonatomic) OHAttributedLabel *mainLabel;
@property (strong, nonatomic) IconButton *iconView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier forWidth:(CGFloat)width timelineCellType:(TimelineCellType)timelineCellType;
- (void)setProperties:(CGFloat)width;
- (void)setTweetData:(TWTweet *)tweet cellWidth:(CGFloat)cellWidth;

@end