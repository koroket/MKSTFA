//
//  FBLogInViewController.m
//  TFE
//
//  Created by Luke Solomon on 9/26/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import "FBLogInViewController.h"
#import "NetworkCommunication.h"
#import "GroupTableViewController.h"

@interface FBLogInViewController ()
@property (weak, nonatomic) IBOutlet FBLoginView *loginView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureView;
@property (weak, nonatomic) IBOutlet UILabel *labelDebug;

#pragma message "IBOutlet connections are typically weak"
@property (strong, nonatomic) IBOutlet UIImageView *splashScreen;

- (IBAction)buttonDebug:(id)sender;
@end


@implementation FBLogInViewController

#pragma mark - init
/**
 * --------------------------------------------------------------------------
 * Init
 * --------------------------------------------------------------------------
 */
- (void)viewDidLoad
{
    [super viewDidLoad];


    
//    [self.navigationController setNavigationBarHidden:YES animated:YES];

    // Necessary
    [NetworkCommunication sharedManager].controllerCurrentLogin = self;
    // Do any additional setup after loading the view.
    
    [NetworkCommunication sharedManager].boolDebug = false;
    _labelDebug.text = @"Off";

    self.loginView.readPermissions = @[ @"public_profile", @"email", @"user_friends" ];
}

#pragma mark - FaceBook Server Communication
/**
 * --------------------------------------------------------------------------
 * FaceBook
 * --------------------------------------------------------------------------
 */
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                    user:(id<FBGraphUser>)user
{
    [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection,NSDictionary<FBGraphUser> *FBUser, NSError *error)
    {
        if (error)
        {
            // Handle error
        }
        else
        {
            //Fetch the profile picture from facebook
            NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [FBUser objectID]];

    #pragma message "use DISPATCH_QUEUE_PRIORITY_DEFAULT instead of 0 for the first parameter for better sematics"
            dispatch_async(dispatch_get_global_queue(0, 0), ^
            {
                UIImage *tempImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:userImageURL]]];
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    self.profilePictureView.image = tempImage;
                    //self.profilePictureView.image =
                });
            });
        }
    }];
    
    self.nameLabel.text = user.name;
    
    //call the singleton for string data
    [NetworkCommunication sharedManager].stringFBUserId = user.objectID;
    [NetworkCommunication sharedManager].stringFBUserName = user.name;
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
    //[[NetworkCommunication sharedManager] getRequests];
//    if([NetworkCommunication sharedManager].stringDeviceToken != nil)
//    {
//        [[NetworkCommunication sharedManager] linkDeviceToken];
//    }
    [self performSegueWithIdentifier:@"ToMainView" sender:self];
    self.statusLabel.text = @"You are logged in as";
    
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    
  self.nameLabel.text = @"";
  self.statusLabel.text = @"You are not logged in";
  [self.splashScreen removeFromSuperview];
}

/**
 *  Handle possible errors that can occur during login
 *
 *  @param loginView
 *  @param error
 */
- (void)loginView:(FBLoginView *)loginView
      handleError:(NSError *)error
{
  NSString *alertMessage, *alertTitle;

  /* If the user should perform an action outside of you app to recover,
   * the SDK will provide a message for the user, you just need to surface it.
   * This conveniently handles cases like Facebook password change or unverified
   * Facebook accounts.
   */

  if ([FBErrorUtility shouldNotifyUserForError:error])
  {
    alertTitle = @"Facebook error";
    alertMessage = [FBErrorUtility userMessageForError:error];

    /* This code will handle session closures that happen outside of the app
     * You can take a look at our error handling guide to know more about it
     * https://developers.facebook.com/docs/ios/errors
    */
  }
  else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession)
  {
    alertTitle = @"Session Error";
    alertMessage = @"Your current session is no longer valid. Please log in again.";

    /* If the user has cancelled a login, we will do nothing.
     * You can also choose to show the user a message if cancelling login will
     * result in
     * the user not being able to complete a task they had initiated in your app
     * (like accessing FB-stored information or posting to Facebook)
    */
  }
  else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled)
  {
    NSLog(@"user cancelled login");

    /* For simplicity, this sample handles other errors with a generic message
     * You can checkout our error handling guide for more detailed information
     * https://developers.facebook.com/docs/ios/errors
    */
  }
  else
  {
    alertTitle = @"Something went wrong";
    alertMessage = @"Please try again later.";
    NSLog(@"Unexpected error:%@", error);
  }

  if (alertMessage)
  {
    [[[UIAlertView alloc] initWithTitle:alertTitle
                                message:alertMessage
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
  }
}

#pragma mark - Navigation
/**
 * --------------------------------------------------------------------------
 * Navigation
 * --------------------------------------------------------------------------
 */

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{

    
}

- (IBAction)unwindToLoginViewController:(UIStoryboardSegue *)unwindSegue
{
    
}

@end
