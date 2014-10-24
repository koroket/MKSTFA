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
@implementation DraggableBackground
{
    //Integers
    NSInteger cardsLoadedIndex; //%%% the index of the card you have loaded into the loadedCards array last
    NSInteger currentCardIndex;
    
    //Arrays
    NSMutableArray *loadedCards; //%%% the array of card loaded (change max_buffer_size to increase or decrease the number of cards this holds)
    
    //Buttons
    IBOutlet UIButton *xButton;
    IBOutlet UIButton *checkButton;
    UIButton* menuButton;
    UIButton* messageButton;
   
}

- (IBAction)good:(id)sender
{
    [self swipeRight];
}

- (IBAction)bad:(id)sender
{
    [self swipeLeft];
}

//this makes it so only two cards are loaded at a time to
//avoid performance and memory costs
static const int MAX_BUFFER_SIZE = 2; //%%% max number of cards loaded at any given time, must be greater than 1
static const float CARD_HEIGHT = 386; //%%% height of the draggable card
static const float CARD_WIDTH = 290; //%%% width of the draggable card

@synthesize exampleCardLabels; //%%% all the labels I'm using as example data at the moment
@synthesize allCards;//%%% all the cards

-(void)viewDidLoad
{
    [super viewDidLoad];
    if (self) {
        [self setupView];
        exampleCardLabels = [NetworkCommunication sharedManager].arraySelectedGroupCardData; //%%% placeholder for card-specific information
        loadedCards = [[NSMutableArray alloc] init];
        allCards = [[NSMutableArray alloc] init];
        cardsLoadedIndex = 0;
        currentCardIndex = -1;

    }
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
            [self loadCards];
    for(int i = 0; i < self.allCards.count; i++)
    {
        [self.allCards[i] setFrame:self.viewContainer.frame];
    }
    
}
//%%% sets up the extra buttons on the screen
-(void)setupView
{
#warning customize all of this.  These are just place holders to make it look pretty
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

#warning include own card customization here!
//%%% creates a card and returns it.  This should be customized to fit your needs.
// use "index" to indicate where the information should be pulled.  If this doesn't apply to you, feel free
// to get rid of it (eg: if you are building cards from data from the internet)
-(Draggable *)createDraggableWithDataAtIndex:(NSInteger)index
{
    Draggable *draggable = [[[NSBundle mainBundle] loadNibNamed:@"SwipeCardView" owner:self options:nil] objectAtIndex:0];
//    Draggable *draggable = [[Draggable alloc]initWithFrame:CGRectMake((self.view.frame.size.width - CARD_WIDTH)/2, (self.view.frame.size.height - CARD_HEIGHT)/2, CARD_WIDTH, CARD_HEIGHT)];

    NSDictionary *tempoaryDict = [exampleCardLabels objectAtIndex:index];
    draggable.information.text = tempoaryDict[@"Name"]; //%%% placeholder for card-specific information
    if(tempoaryDict[@"ImageURL"]!=nil)
    {
        NSString* newString = tempoaryDict[@"ImageURL"];
        NSString* new2String = [newString stringByReplacingOccurrencesOfString:@"/ms.jpg" withString:@"/o.jpg"];
          draggable.imageView.image  = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:new2String]]];
    }
  
    draggable.delegate = self;
    return draggable;
}

//%%% loads all the cards and puts the first x in the "loaded cards" array
-(void)loadCards
{
    if([exampleCardLabels count] > 0)
    {
        NSInteger numLoadedCardsCap =(([exampleCardLabels count] > MAX_BUFFER_SIZE)?MAX_BUFFER_SIZE:[exampleCardLabels count]);
        //%%% if the buffer size is greater than the data size, there will be an array error, so this makes sure that doesn't happen
        
        //%%% loops through the exampleCardsLabels array to create a card for each label.  This should be customized by removing "exampleCardLabels" with your own array of data
        for (int i = 0; i<[exampleCardLabels count]; i++)
        {
            Draggable* newCard = [self createDraggableWithDataAtIndex:i];
            [allCards addObject:newCard];
            
            if (i<numLoadedCardsCap)
            {
                //%%% adds a small number of cards to be loaded
                [loadedCards addObject:newCard];
            }
        }
        
        //%%% displays the small number of loaded cards dictated by MAX_BUFFER_SIZE so that not all the cards
        // are showing at once and clogging a ton of data
        for (int i = 0; i<[loadedCards count]; i++) {
            if (i>0)
            {
                [self.view insertSubview:[loadedCards objectAtIndex:i] belowSubview:[loadedCards objectAtIndex:i-1]];
            }
            else
            {
                [self.view addSubview:loadedCards[i]];
                
                
            }
            cardsLoadedIndex++; //%%% we loaded a card into loaded cards, so we have to increment
        }
    }
}

#warning include own action here!
//%%% action called when the card goes to the left.
// This should be customized with your own action
-(void)cardSwipedLeft:(UIView *)card;
{
    //do whatever you want with the card that was swiped
    //DraggableView *c = (DraggableView *)card;
    currentCardIndex++;
    
    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    
    if (cardsLoadedIndex < [allCards count])
    { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        
        [self.view insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
    }
}

#warning include own action here!
//%%% action called when the card goes to the right.
// This should be customized with your own action
-(void)cardSwipedRight:(UIView *)card
{
    //do whatever you want with the card that was swiped
    //    DraggableView *c = (DraggableView *)card;
    
    currentCardIndex++;
    
    [self yesWith:currentCardIndex andUrl: [NetworkCommunication sharedManager].stringSelectedGroupID];
    
    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    
    if (cardsLoadedIndex < [allCards count])
    {
        //%%% if we haven't reached the end of all cards, put another into the loaded cards
        
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        
        [self.view insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
    }
    
}

//%%% when you hit the right button, this is called and substitutes the swipe
-(void)swipeRight
{
    Draggable *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeRight;
    [UIView animateWithDuration:0.2 animations:^
    {
        dragView.overlayView.alpha = 1;
    }];
    [dragView rightClickAction];
}

//%%% when you hit the left button, this is called and substitutes the swipe
-(void)swipeLeft
{
    Draggable *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeLeft;
    [UIView animateWithDuration:0.2 animations:^
    {
        dragView.overlayView.alpha = 1;
    }];
    [dragView leftClickAction];
}

-(void)checkForGroupAgreement
{

}

/**
 *  Handles what happens when you say yes to a card
 *
 *  @param index - the array index of the card
 *  @param groupID - The unique ID of the group
 */
-(void)yesWith:(int)index andUrl:(NSString*) groupID
{
    #pragma message "Backend Code should be in separate class. Is this a duplicate of the other 'yesWith:...' method?"
    //URL
    NSString *fixedUrl = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/groups/%@/%d",
                          groupID,
                          index];
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
                NSNumber *t = dictionaryHerokuResponses[@"NumberOfReplies"];
                if ([t intValue] == [NetworkCommunication sharedManager].intSelectedGroupNumberOfPeople)
                {
                    
                    //get the array of device tokens from the singleton
                    NSArray *temparray = [NetworkCommunication sharedManager].arraySelectedGroupDeviceTokens;
                    
                    for (int i = 0; i < [NetworkCommunication sharedManager].intSelectedGroupNumberOfPeople; i++)
                    {
                        [self sendNotification:temparray[i] withIndex:index withGroupid:groupID];
                    }
                    //[self performSegueWithIdentifier:@"Done" sender:self];
                }
                else
                {
                    
                }
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
}

-(void)finalWith:(int)index andUrl:(NSString*) tempUrl
{
    //URL
    NSString *fixedUrl = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/groups/%@/%d/finished",
                          tempUrl,
                          index];
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
                NSMutableDictionary* hhh = [NSJSONSerialization JSONObjectWithData:data
                                                                           options:0
                                                                             error:nil];
                NSNumber *t = hhh[@"NumberOfReplies"];
                if ([t intValue] == [NetworkCommunication sharedManager].intSelectedGroupNumberOfPeople)
                {
                    //[self performSegueWithIdentifier:@"Done" sender:self];
                }
                else
                {
                    NSLog(@"No Match Yet%d",[NetworkCommunication sharedManager].intSelectedGroupNumberOfPeople);
                }
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
    
}

- (void)sendNotification:(NSString*)temptoken withIndex:(int) daindex withGroupid: (NSString*) groupID
{
    //URL
    NSString *fixedUrl = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/token/push/%@/%d/%@",
                          temptoken,
                          daindex,
                          groupID];
    NSURL *url = [NSURL URLWithString:fixedUrl];

    //Request
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:url
                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                        timeoutInterval:30.0];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";

    //Session
    NSURLSession *urlSession = [NSURLSession sharedSession];
    
    NSDictionary *dictionary = [exampleCardLabels objectAtIndex:daindex];
    
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary
                                                   options:kNilOptions
                                                     error:&error];
    
    //Data Task
    NSURLSessionUploadTask *uploadTask =
    [urlSession uploadTaskWithRequest:request
                          fromData:data
                 completionHandler:^(NSData *data,
                                     NSURLResponse *response,
                                     NSError *error)
     {
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSInteger responseStatusCode = [httpResponse statusCode];
    
    if (responseStatusCode == 200 && data)
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
              
        });

        // do something with this data
        // if you want to update UI, do it on main queue

        }
        else
        {
          // error handling
          NSLog(@"gucci");
        }
        dispatch_async(dispatch_get_main_queue(),^
        {
          
        });
    }];
    [uploadTask resume];
}
-(void)showCompletion:(NSDictionary*)dict
{
    AMSmoothAlertView *alert = [[AMSmoothAlertView alloc]initDropAlertWithTitle:@"Match Found!" andText:dict[@"Name"] andCancelButton:YES forAlertType:AlertSuccess];
    [alert show];
}

@end

