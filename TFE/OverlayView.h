//
//  OverlayView.h
//  TFE
//
//  Created by Luke Solomon on 9/29/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#pragma message "Please check license and include original author when using code from examples/tutorials/etc"

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSUInteger, GGOverlayViewMode) {
	GGOverlayViewModeLeft,
	GGOverlayViewModeRight
};

@interface OverlayView : UIView

@property (nonatomic) GGOverlayViewMode mode;
@property (nonatomic, strong) UIImageView *imageView;

@end
