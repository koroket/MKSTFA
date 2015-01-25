//
//  DraggableBackground.m
//  TFE
//
//  Created by Luke Solomon on 9/29/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//
#pragma message "Is this class written by you? If not you should include a copyright header"

#import "DraggableBackground.h"
#import "NetworkCommunication.h"
#import "AMSmoothAlertView.h"
#import "MBProgressHUD.h"

#import <CoreLocation/CoreLocation.h>

@interface DraggableBackground () <CLLocationManagerDelegate>

@end

@implementation DraggableBackground {
    NSInteger cardsLoadedIndex; //%%% the index of the card you have loaded into the loadedCards array last
    NSInteger currentCardIndex;
    NSMutableArray *loadedCards; //%%% the array of card loaded (change max_buffer_size to increase or decrease the number of cards this holds)
    IBOutlet UIButton *xButton;
    IBOutlet UIButton *checkButton;
    UIButton* menuButton;
    UIButton* messageButton;

}

- (IBAction)good:(id)sender {
    [self swipeRight];
}

- (IBAction)bad:(id)sender {
    [self swipeLeft];
}

//this makes it so only two cards are loaded at a time to
//avoid performance and memory costs
static const int MAX_BUFFER_SIZE = 2; //%%% max number of cards loaded at any given time, must be greater than 1
@synthesize exampleCardLabels; //%%% all the labels I'm using as example data at the moment
@synthesize allCards;//%%% all the cards

-(void)viewDidLoad {
    [super viewDidLoad];
    if (self) {
            self.offset = 0;
        exampleCardLabels = [NetworkCommunication sharedManager].arraySelectedGroupCardData;
        loadedCards = [[NSMutableArray alloc] init];
        allCards = [[NSMutableArray alloc] init];
        cardsLoadedIndex = 0;
        currentCardIndex = -1;
        NSInteger numLoadedCardsCap =(([exampleCardLabels count] > MAX_BUFFER_SIZE)?MAX_BUFFER_SIZE:[exampleCardLabels count]);
        for (int i = 0; i<[exampleCardLabels count]; i++) {
            Draggable* newCard = [self createDraggableWithDataAtIndex:i];
            [allCards addObject:newCard];
        }
        [self setupView];
        //%%% if the buffer size is greater than the data size, there will be an array error, so this makes sure that doesn't happen
        //%%% loops through the exampleCardsLabels array to create a card for each label.  This should be customized by removing "exampleCardLabels" with your own array of data
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"Loading";
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadCards];
    [self createOverLaysMain];

    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

-(void)createOverLaysMain {
    for(int i = 0; i<self.allCards.count;i++) {
        [self.allCards[i] createOverLay];
    }
}

//%%% sets up the extra buttons on the screen
-(void)setupView {
   self.view.backgroundColor = [UIColor colorWithRed:.92 green:.93 blue:.95 alpha:1]; //the gray background colors
    menuButton = [[UIButton alloc]initWithFrame:CGRectMake(17, 34, 22, 15)];
    [menuButton setImage:[UIImage imageNamed:@"menuButton"] forState:UIControlStateNormal];
    messageButton = [[UIButton alloc]initWithFrame:CGRectMake(284, 34, 18, 18)];
    [messageButton setImage:[UIImage imageNamed:@"messageButton"] forState:UIControlStateNormal];
    [xButton setImage:[UIImage imageNamed:@"xButton"] forState:UIControlStateNormal];
    [checkButton setImage:[UIImage imageNamed:@"checkButton"] forState:UIControlStateNormal];
    [self.view addSubview:menuButton];
    [self.view addSubview:messageButton];
}

// Perform on background queue %%% creates a card and returns it.  This should be customized to fit your needs. use "index" to indicate where the information should be pulled.  If this doesn't apply to you, feel free to get rid of it (eg: if you are building cards from data from the internet)
-(Draggable *)createDraggableWithDataAtIndex:(NSInteger)index {
    Draggable *draggable = [[[NSBundle mainBundle] loadNibNamed:@"SwipeCardView" owner:self options:nil] objectAtIndex:0];
    //    Draggable *draggable = [[Draggable alloc]initWithFrame:CGRectMake((self.view.frame.size.width - CARD_WIDTH)/2, (self.view.frame.size.height - CARD_HEIGHT)/2, CARD_WIDTH, CARD_HEIGHT)];
    NSDictionary *tempoaryDict = [exampleCardLabels objectAtIndex:index];
    draggable.information.text = tempoaryDict[@"Name"]; //%%% placeholder for card-specific information
    if(tempoaryDict[@"ImageURL"]!=nil) {
        NSString* newString = tempoaryDict[@"ImageURL"];
        NSString* new2String = [newString stringByReplacingOccurrencesOfString:@"/ms.jpg" withString:@"/o.jpg"];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UIImage *tempImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:new2String]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                 draggable.imageView.image  = tempImage;
            });
        });
    }
    if(tempoaryDict[@"rating"]!=nil) {
        NSNumber *k = tempoaryDict[@"rating"];
        draggable.rating.text  = [NSString stringWithFormat:@"%.1f Rating",[k doubleValue]];
    }
    if(tempoaryDict[@"distance"]!=nil) {
        NSNumber *k = tempoaryDict[@"distance"];
        double meters = [k doubleValue];
        double miles = meters/1600.0;
        draggable.distance.text  = [NSString stringWithFormat:@"%.1f mi",miles];
    }
    if(tempoaryDict[@"Category"]!=nil) {
        NSArray *cats = tempoaryDict[@"Category"];
        NSString* catsString = @"";
        for(int i = 0; i < cats.count;i++) {
            catsString = [NSString stringWithFormat:@"%@ %@",catsString,cats[i]];
        }
        draggable.categories.text  = catsString;
    }
    draggable.delegate = self;
    return draggable;
}

//%%% loads all the cards and puts the first x in the "loaded cards" array
-(void)loadCards {
    if([exampleCardLabels count] > 0) {
        NSLog(@"done");
        //%%% displays the small number of loaded cards dictated by MAX_BUFFER_SIZE so that not all the cards
        // are showing at once and clogging a ton of data
        for (int i = 0; i<[loadedCards count]; i++) {
            if (i>0) {
                [self.view insertSubview:[loadedCards objectAtIndex:i] belowSubview:[loadedCards objectAtIndex:i-1]];
            } else {
                [self.view addSubview:loadedCards[i]];
            }
            cardsLoadedIndex++; //%%% we loaded a card into loaded cards, so we have to increment
        }
        for(int i = 0; i < self.allCards.count; i++) {
            [self.allCards[i] setFrame:self.viewContainer.frame];
        }
    }
}

//%%% action called when the card goes to the left.
// This should be customized with your own action
-(void)cardSwipedLeft:(UIView *)card; {
    //do whatever you want with the card that was swiped
    //DraggableView *c = (DraggableView *)card;
    currentCardIndex++;
    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    if (cardsLoadedIndex < [allCards count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        [self.view insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
    }
}

//%%% action called when the card goes to the right.
// This should be customized with your own action
-(void)cardSwipedRight:(UIView *)card {
    currentCardIndex++;
   // [self yesWith:currentCardIndex andUrl: [NetworkCommunication sharedManager].stringSelectedGroupID];
    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    if (cardsLoadedIndex < [allCards count]) {
        //%%% if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        [self.view insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
    }
    
}

//%%% when you hit the right button, this is called and substitutes the swipe
-(void)swipeRight {
    Draggable *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeRight;
    [UIView animateWithDuration:0.2 animations:^ {
        dragView.overlayView.alpha = 1;
    }];
    [dragView rightClickAction];
}

//%%% when you hit the left button, this is called and substitutes the swipe
-(void)swipeLeft {
    Draggable *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeLeft;
    [UIView animateWithDuration:0.2 animations:^ {
        dragView.overlayView.alpha = 1;
    }];
    [dragView leftClickAction];
}


/*-(void)yesWith:(int)index andUrl:(NSString*) groupID
{
    #pragma message "Backend Code should be in separate class. Is this a duplicate of the other 'yesWith:...' method?"
    //URL
    NSString *fixedUrl = [NSString stringWithFormat:@"http://tinder-for-anything.herokuapp.com/groups/%@/%d/%@/%@groups/%d",
                          groupID,
                          index+[NetworkCommunication sharedManager].intSelectedGroupProgressIndex,
                          [NetworkCommunication sharedManager].stringCurrentDB,
                          [NetworkCommunication sharedManager].stringFBUserId,
                          [NetworkCommunication sharedManager].intSelectedGroupNumberOfPeople];
    NSURL *url = [NSURL URLWithString:fixedUrl];
    
    //Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    [request setHTTPMethod:@"PUT"];

    //Session
    NSURLSession *urlSession = [NSURLSession sharedSession];
    
    //Data Task Block
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request
                                                   completionHandler:^(NSData *data,
                                                                       NSURLResponse *response,
                                                                       NSError *error)
    {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        NSInteger responseStatusCode = [httpResponse statusCode];
        
        if (responseStatusCode == 200 && data)
        {
            dispatch_async(dispatch_get_main_queue(), ^(void)
            {

                NSMutableDictionary* dictionaryHerokuResponses = [NSJSONSerialization JSONObjectWithData:data
                                                                           options:0
                                                                             error:nil];
                NSLog(@"%@",dictionaryHerokuResponses);
                
                NSNumber *t = dictionaryHerokuResponses[@"NumberOfReplies"];


            });
            // do something with this data
            // if you want to update UI, do it on main queue
        }
        else
        {
            // error handling
        }
    }];
    [dataTask resume];
}*/

-(void)getMoreYelp {
    NSString *fixedURL = [NSString stringWithFormat:@"http://tinder-for-anything.herokuapp.com/yelp/%@/%@/%@/%d",
                          [NetworkCommunication sharedManager].stringCurrentLatitude,
                          [NetworkCommunication sharedManager].stringCurrentLongitude,
                          @"restaurants",
                          self.offset
                          ];
    NSURL *url = [NSURL URLWithString:fixedURL];
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setHTTPMethod:@"GET"];
    NSURLSession *urlSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask =
    [urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
         NSInteger responseStatusCode = [httpResponse statusCode];
         if (responseStatusCode == 200 && data) {
             dispatch_async(dispatch_get_main_queue(), ^(void) {
                 NSArray*fetchedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
#pragma message "You are using this for preloading, right?; You should add some comments"
                 self.offset +=20;
                 exampleCardLabels = [fetchedData mutableCopy];
                 for (int i = 0; i<20; i++) {
                     Draggable* newCard = [self createDraggableWithDataAtIndex:i];
                     [allCards addObject:newCard];
                 }
             });
         } else {
             // error handling
         }
     }]; // Data Task Block
    [dataTask resume];
}

-(void)showCompletion:(NSDictionary*)dict {
    AMSmoothAlertView *alert = [[AMSmoothAlertView alloc]initDropAlertWithTitle:@"Match Found!" andText:dict[@"Name"] andCancelButton:YES forAlertType:AlertSuccess];
    [alert show];
}




@end

