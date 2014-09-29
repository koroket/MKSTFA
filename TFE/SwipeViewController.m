//
//  SwipeViewController.m
//  TFE
//
//  Created by Luke Solomon on 9/29/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import "SwipeViewController.h"
#import "DraggableBackground.h"

@interface SwipeViewController ()

@end

@implementation SwipeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    DraggableBackground *draggableBackground = [[DraggableBackground alloc]initWithFrame:self.view.frame];
    
    [self.view addSubview:draggableBackground];
}

@end
