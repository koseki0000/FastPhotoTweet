//
//  TimelineStyledCellController.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/10/14.
//

#import <UIKit/UIKit.h>
#import <Three20UI/Three20UI.h>
#import <Three20UICommon/Three20UICommon.h>
#import <Three20Style/Three20Style.h>

@interface TimelineStyledCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIButton *iconView;
@property (retain, nonatomic) IBOutlet UILabel *infoLabel;
@property (retain, nonatomic) IBOutlet TTStyledTextLabel *mainLabel;

@end

@interface TimelineStyledCellController : UIViewController

@property (retain, nonatomic) IBOutlet TimelineStyledCell *styledCell;

@end
