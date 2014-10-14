//
//  Draggable.h
//  TFE
//
//  Created by Luke Solomon on 9/29/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OverlayView.h"

@protocol DraggableDelegate <NSObject>

-(void)cardSwipedLeft:(UIView *)card;
-(void)cardSwipedRight:(UIView *)card;

@end

@interface Draggable : UIView

@property (weak) id <DraggableDelegate> delegate;

@property (nonatomic, strong)UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic)CGPoint originalPoint;
@property (nonatomic,strong)OverlayView* overlayView;
@property (nonatomic,strong)UILabel* information; //%%% a placeholder for any card-specific information
@property (nonatomic,strong)UIImageView* imageView; //%%% a placeholder for any card-specific information
-(void)leftClickAction;
-(void)rightClickAction;

@end
