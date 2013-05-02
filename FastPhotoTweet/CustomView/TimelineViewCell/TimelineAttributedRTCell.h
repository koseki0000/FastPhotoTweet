//
//  TimelineAttributedRTCell.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/11/18.
//
//

#import <UIKit/UITableViewCell.h>
#import "OHAttributedLabel.h"
#import "IconButton.h"

@interface TimelineAttributedRTCell : UITableViewCell

@property (strong, nonatomic) UILabel *infoLabel;
@property (strong, nonatomic) OHAttributedLabel *mainLabel;
@property (strong, nonatomic) IconButton *iconView;

@property (strong, nonatomic) UIImageView *userIconView;
@property (strong, nonatomic) UIImageView *rtUserIconView;
@property (strong, nonatomic) UIImageView *arrowView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier forWidth:(CGFloat)width;
- (void)setProperties:(CGFloat)width;
- (void)setTweetData:(TWTweet *)tweet cellWidth:(CGFloat)cellWidth;

@end