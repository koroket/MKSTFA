//
//  OverlayView.h
//  TFE
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSUInteger, GGOverlayViewMode) {
	GGOverlayViewModeLeft,
	GGOverlayViewModeRight
};

@interface OverlayView : UIView

@property (nonatomic) GGOverlayViewMode mode;
@property (nonatomic, strong) UIImageView *imageView;

@end
