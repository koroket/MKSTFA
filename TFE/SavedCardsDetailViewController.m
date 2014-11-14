//
//  SavedCardsDetailViewController.m
//  TFE
//
//  Created by Luke Solomon on 11/13/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import "SavedCardsDetailViewController.h"
#import "NetworkCommunication.h"
@interface SavedCardsDetailViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *imageview;
@property (strong, nonatomic) IBOutlet UILabel *placesLabel;
@property (strong, nonatomic) IBOutlet UILabel *distLabel;
@property (strong, nonatomic) IBOutlet UILabel *ratingLabel;
@property (strong, nonatomic) IBOutlet UILabel *categoryLabel;
@property (strong, nonatomic) IBOutlet UILabel *hoursLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation SavedCardsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadMyData];
}
-(void)loadMyData
{
    self.priceLabel.text = [NetworkCommunication sharedManager].currentCard.price;
    self.distLabel.text = [NetworkCommunication sharedManager].currentCard.distance;
    self.ratingLabel.text = [NetworkCommunication sharedManager].currentCard.rating;
    self.categoryLabel.text = [NetworkCommunication sharedManager].currentCard.categories;
    self.hoursLabel.text = [NetworkCommunication sharedManager].currentCard.hours;
    self.placesLabel.text = [NetworkCommunication sharedManager].currentCard.name;
    self.imageview.image = [UIImage imageWithData:[NetworkCommunication sharedManager].currentCard.image];
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
