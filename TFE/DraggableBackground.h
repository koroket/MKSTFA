//
//  DraggableBackground.h
//  TFE
//
//  Created by Luke Solomon on 9/29/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Draggable.h"

@interface DraggableBackground : UIView <DraggableDelegate>

// methods called in DraggableView
- (void)cardSwipedLeft:(UIView *)card;
- (void)cardSwipedRight:(UIView *)card;

@property (retain, nonatomic) NSArray *exampleCardLabels;  //%%% the labels the cards
@property (retain, nonatomic) NSMutableArray *allCards;    //%%% the labels the cards
@property (nonatomic, strong) NSArray *restaurants;

@end
