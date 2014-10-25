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

-(void)leftClickAction;
-(void)rightClickAction;
-(void)createOverLay;

@property (weak) id <DraggableDelegate> delegate;

//CGPoint
@property (nonatomic)CGPoint originalPoint;


@property (nonatomic, strong)UIPanGestureRecognizer *panGestureRecognizer;

@property (nonatomic,strong)OverlayView* overlayView;

@property (strong, nonatomic) IBOutlet UILabel *information;

//%%% a placeholder for any card-specific information
@property (strong, nonatomic) IBOutlet UIImageView *imageView;



@end
