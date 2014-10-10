//
//  OverlayView.m
//  TFE
//
//  Created by Luke Solomon on 9/29/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import "OverlayView.h"

@implementation OverlayView
@synthesize imageView;

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		self.backgroundColor = [UIColor whiteColor];
		imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"noButton"]];
		[self addSubview:imageView];
	}
	return self;
}

- (void)setMode:(GGOverlayViewMode)mode {
	if (_mode == mode) {
		return;
	}

	_mode = mode;

	if (mode == GGOverlayViewModeLeft) {
		imageView.image = [UIImage imageNamed:@"noButton"];
	}
	else {
		imageView.image = [UIImage imageNamed:@"yesButton"];
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	imageView.frame = CGRectMake(50, 50, 100, 100);
}

/*
   // Only override drawRect: if you perform custom drawing.
   // An empty implementation adversely affects performance during animation.
   - (void)drawRect:(CGRect)rect
   {
   // Drawing code
   }
 */

@end
