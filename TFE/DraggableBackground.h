//
//  DraggableBackground.h
//  TFE
//
//  Created by Luke Solomon on 9/29/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Draggable.h"

@interface DraggableBackground : UIViewController <DraggableDelegate, CLLocationManagerDelegate>

//methods called in DraggableBackground
-(void)cardSwipedLeft:(UIView *)card;
-(void)cardSwipedRight:(UIView *)card;
-(void)showCompletion:(NSDictionary*)dict;

//viewContainers
@property (strong, nonatomic) IBOutlet UIView *viewContainer;

//arrays
@property (retain,nonatomic)NSMutableArray* exampleCardLabels; //%%% the labels the cards
@property (retain,nonatomic)NSMutableArray* allCards; //%%% the labels the cards
@property (nonatomic, strong)NSArray* restaurants;

//strings
@property (nonatomic,strong) NSString* groupID;

//ints
@property (nonatomic,assign) int numOfPeople;
@property (nonatomic,assign) int offset;

@end
