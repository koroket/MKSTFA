//
//  FBLogInViewController.m
//  TFE
//
//  Created by Luke Solomon on 9/26/14.
//  Copyright (c) 2014 SoloBando Enterprises. All rights reserved.
//

#import "FBLogInViewController.h"
#import "NetworkCommunication.h"

@interface FBLogInViewController ()
@property(weak, nonatomic) IBOutlet FBLoginView *loginView;
@property(weak, nonatomic) IBOutlet UILabel *statusLabel;
@property(weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureView;

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
  // Do any additional setup after loading the view.
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
    [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection,
                                                           NSDictionary<FBGraphUser> *FBUser,
                                                           NSError *error)
    {
        if (error)
        {
            // Handle error
        }
        
        else {
            //Fetch the profile picture from facebook
            NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [FBUser objectID]];
            
            //set the UIImageView's Image = to the fetched fbook pic
            self.profilePictureView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:userImageURL]]];
        }
    }];
    self.nameLabel.text = user.name;
    
    //call the singleton for string data
    [NetworkCommunication sharedManager].stringFBUserId = user.objectID;
    [NetworkCommunication sharedManager].stringFBUserName = user.name;

    
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
  /*
   * NSLog(userid);

   * NSString *storyboardName = @"Main";
   * UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName
   * bundle:nil];
   
   * UIViewController *vc = [storyboard
   * instantiateViewControllerWithIdentifier:@"TableView"];
   * [[self navigationController] pushViewController:vc animated:YES];
   * [self presentViewController:vc animated:YES completion:nil];
   */
  
    self.statusLabel.text = @"You're logged in as";
    //

}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
  // self.profilePictureView.profileID = nil;
  self.nameLabel.text = @"";
  self.statusLabel.text = @"You're not logged in!";
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

- (void)linkDeviceToken
{
    //URL
    NSString *fixedUrl = [NSString stringWithFormat:@"http://young-sierra-7245.herokuapp.com/token/%@token",
                          [NetworkCommunication sharedManager].stringFBUserId];
    NSURL *url = [NSURL URLWithString:fixedUrl];

    //Session
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];

    //Request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";

    //Dictionary
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NetworkCommunication sharedManager].stringDeviceToken,
                                @"token",
                                nil];
    //errorHandlign
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary
                                                   options:kNilOptions
                                                     error:&error];
    if (!error)
    {
        //Upload
        NSURLSessionUploadTask *uploadTask =
        [session uploadTaskWithRequest:request
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
                    NSArray *fetchedData = [NSJSONSerialization JSONObjectWithData:data
                                                                           options:0
                                                                             error:nil];
                    NSDictionary *data1 = [fetchedData objectAtIndex:0];
                    
                    
                    
                    [self performSegueWithIdentifier:@"LoggedIn" sender:self];
                });
             }
             
         }];
        
        [uploadTask resume];
        NSLog(@"Connected to server");
    }
    else
    {
        NSLog(@"Cannot connect to server");
    }
}


#pragma mark - Navigation
/**
 * --------------------------------------------------------------------------
 * Navigation
 * --------------------------------------------------------------------------
 */

/*
// In a storyboard-based application, you will often want to do a little
preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue 
                 sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
