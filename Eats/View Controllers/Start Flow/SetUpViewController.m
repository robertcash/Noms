//
//  SetUpViewController.m
//  Eats
//
//  Created by Robert Cash on 11/21/15.
//  Copyright © 2015 Robert Cash. All rights reserved.
//
#import "UserCache.h"
#import "BackendClass.h"
#import "ProgressHUD.h"
#import "PBJVideoView.h"
#import "PBJVideoPlayerController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SetUpViewController.h"

@interface SetUpViewController ()<PBJVideoPlayerControllerDelegate,FBSDKLoginButtonDelegate,CLLocationManagerDelegate,CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *yesButton;
@property (weak, nonatomic) IBOutlet UIButton *noButton;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet FBSDKLoginButton *facebookLoginButton;

@end

@implementation SetUpViewController{
    // Data
    NSString *userId;
    NSString *name;
    NSString *school;
    
    // UI
    PBJVideoPlayerController *videoPlayerController;
    ProgressHUD *progressHUD;
    
    // Data
    BackendClass *backendClass;
    UserCache *userCache;
    
    // Other
    CLLocationManager *locationManager;
    int stepInSetup;
}

#pragma mark - Setup Code

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpUI];
    [self setUpData];
    stepInSetup = 0;
    locationManager =[[CLLocationManager alloc]init];
}

-(void)viewDidAppear:(BOOL)animated{
    // Remove tap gesture for curl
    for(UIGestureRecognizer *gesture in [self.view gestureRecognizers]){
        if([gesture isKindOfClass:[UIGestureRecognizer class]]){
            [self.view removeGestureRecognizer:gesture];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setUpData{
    userCache = [[UserCache alloc]init];
    backendClass = [[BackendClass alloc]init];
    
}

-(void)setUpUI{
    // allocate video controller
    videoPlayerController = [[PBJVideoPlayerController alloc] init];
    videoPlayerController.delegate = self;
    videoPlayerController.view.frame = self.view.bounds;
    [videoPlayerController setVolume:0.0];
    [videoPlayerController setVideoFillMode:@"AVLayerVideoGravityResizeAspectFill"];
    
    // setup media
    NSURL *myURL =[[NSBundle mainBundle] URLForResource:@"pizza" withExtension:@"mp4"];
    videoPlayerController.videoPath = [myURL absoluteString];
    
    // present video
    [self addChildViewController:videoPlayerController];
    [self.view addSubview:videoPlayerController.view];
    [videoPlayerController didMoveToParentViewController:self];
    [videoPlayerController playFromBeginning];
    

    // Set up blur view
    self.view.backgroundColor = [UIColor clearColor];
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.alpha = 0.4f;
    
    blurEffectView.frame = self.view.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:blurEffectView];
    [self addUIToView];
    
    // Setup Facebook Button
    self.facebookLoginButton.delegate = self;
    self.facebookLoginButton.readPermissions =
    @[@"public_profile", @"user_events", @"user_education_history"];
    
    // Setup Other Buttons
    self.yesButton.layer.cornerRadius = 5;
    self.yesButton.clipsToBounds = YES;
    [[self.yesButton layer] setBorderWidth:3.0f];
    [[self.yesButton layer] setBorderColor:[UIColor whiteColor].CGColor];
    self.noButton.layer.cornerRadius = 5;
    self.noButton.clipsToBounds = YES;
    [[self.noButton layer] setBorderWidth:3.0f];
    [[self.noButton layer] setBorderColor:[UIColor whiteColor].CGColor];
    self.okButton.layer.cornerRadius = 5;
    self.okButton.clipsToBounds = YES;
    [[self.okButton layer] setBorderWidth:3.0f];
    [[self.okButton layer] setBorderColor:[UIColor whiteColor].CGColor];
    [self.yesButton setAlpha:0.0f];
    [self.noButton setAlpha:0.0f];
    [self.okButton setAlpha:0.0f];
    
    // Init Progress HUD
    progressHUD = [[ProgressHUD alloc]init];
    
}

-(void)addUIToView{
    [self.view addSubview:self.headerLabel];
    [self.view addSubview:self.descriptionLabel];
    [self.view addSubview:self.yesButton];
    [self.view addSubview:self.noButton];
    [self.view addSubview:self.okButton];
    [self.view addSubview:self.facebookLoginButton];
}

#pragma mark Facebook Code

- (void)
loginButton:	(FBSDKLoginButton *)loginButton
didCompleteWithResult:	(FBSDKLoginManagerLoginResult *)result
error:	(NSError *)error{
    
    [UIView animateWithDuration:0.5f animations:^{
        
    } completion:^(BOOL finished) {
    }];
    if(error){
        
        NSLog(@"error %@",error);
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Error"
                                              message:@"No connection!"
                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Ok", @"OK action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       [alertController removeFromParentViewController];
                                   }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        [UIView animateWithDuration:0.5f animations:^{
            [self.facebookLoginButton setAlpha:1.0f];
        } completion:^(BOOL finished) {
        }];
        
    }
    else if([FBSDKAccessToken currentAccessToken]){
        [self getFacebookInfo];
    }
    [videoPlayerController playFromCurrentTime];
}

- (void) loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
}

-(void)getFacebookInfo{
    [progressHUD show];
    // Get Facebook Info
    NSDictionary *params = @{};
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:@"/me?fields=name,id,education,events"
                                  parameters:params
                                  HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        // Handle the result
        if(error){
            [progressHUD hide];
            NSLog(@"error");
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@"Error"
                                                  message:@"No connection! "
                                                  preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"Ok", @"OK action")
                                       style:UIAlertActionStyleDestructive
                                       handler:^(UIAlertAction *action)
                                       {
                                           [alertController removeFromParentViewController];
                                       }];
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
            [UIView animateWithDuration:0.5f animations:^{
                [self.facebookLoginButton setAlpha:1.0f];
            } completion:^(BOOL finished) {
            }];
        }
        else{
            NSDictionary *facebookResult = (NSDictionary *)result;
             userId = facebookResult[@"id"];
            name = facebookResult[@"name"];
            // Go through education
            NSArray *educations = facebookResult[@"education"];
            if([educations count] > 0){
                NSDictionary *userEducation = [educations lastObject];
                if(![userEducation[@"type"]isEqualToString:@"College"]){
                    for (NSDictionary *education in educations){
                        if([education[@"type"]isEqualToString:@"College"]){
                            userEducation = education;
                            break;
                        }
                        else{
                            userEducation = @{@"school":@{@"name":@"none"}};
                        }
                    }
                }
                school = userEducation[@"school"][@"name"];
            }
            else{
                school = @"none";
            }
            [videoPlayerController playFromCurrentTime];
            [self.facebookLoginButton setAlpha:0.0f];
            [progressHUD hide];
            stepInSetup = 1;
            [self transitionText];
        }
    }];

}

#pragma mark - PBJVideoPlayerControllerDelegate

- (void)videoPlayerReady:(PBJVideoPlayerController *)videoPlayer
{
}

- (void)videoPlayerPlaybackStateDidChange:(PBJVideoPlayerController *)videoPlayer
{
}

- (void)videoPlayerBufferringStateDidChange:(PBJVideoPlayerController *)videoPlayer
{
}

- (void)videoPlayerPlaybackWillStartFromBeginning:(PBJVideoPlayerController *)videoPlayer
{
}

- (void)videoPlayerPlaybackDidEnd:(PBJVideoPlayerController *)videoPlayer
{
    [videoPlayer playFromBeginning];
}

#pragma IB Action Code

- (IBAction)yes:(id)sender {
    // Login User
    [progressHUD show];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self loginUser:1];
    });
    
}

- (IBAction)no:(id)sender {
    // Login User
    [progressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self loginUser:0];
    });
}

- (IBAction)ok:(id)sender {
    // Ask For Location Services
    [locationManager requestWhenInUseAuthorization];
    while([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined){
        
    }
    
    [videoPlayerController playFromCurrentTime];
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status==kCLAuthorizationStatusDenied) {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"Location Services Required"
                                              message:@"In order for this app to function, your permission for location services must be given. Go to your settings to allow location services."
                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Ok"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       [alertController removeFromParentViewController];
                                   }];
        UIAlertAction *settingsAction = [UIAlertAction
                                   actionWithTitle:@"Settings"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                       [[UIApplication sharedApplication]openURL:settingsURL];
                                       [alertController removeFromParentViewController];
                                   }];
        [alertController addAction:cancelAction];
        [alertController addAction:settingsAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    if (status==kCLAuthorizationStatusAuthorizedWhenInUse) {
        // Move on in process
        [locationManager startUpdatingLocation];
        stepInSetup = 2;
        [self transitionText];
    }
    
}


-(void)transitionText{
    if(stepInSetup == 1){
        [UIView animateWithDuration:0.5f animations:^{
            [self.headerLabel setAlpha:0.0f];
            [self.descriptionLabel setAlpha:0.0f];
            [self.facebookLoginButton setAlpha:0.0f];
        } completion:^(BOOL finished) {
            self.headerLabel.text = @"Enable Location Services";
            self.descriptionLabel.text = @"Your location is needed to find free food events near you. Location is used only when the app is in use.";
            [UIView animateWithDuration:0.5f animations:^{
                [self.headerLabel setAlpha:1.0f];
                [self.descriptionLabel setAlpha:1.0f];
                [self.okButton setAlpha:1.0f];
            } completion:^(BOOL finished) {
            }];
        }];
    }
    else{
        [UIView animateWithDuration:0.5f animations:^{
            [self.headerLabel setAlpha:0.0f];
            [self.descriptionLabel setAlpha:0.0f];
            [self.okButton setAlpha:0.0f];
        } completion:^(BOOL finished) {
            self.headerLabel.text = @"Enable Notifications?";
            self.descriptionLabel.text = @"We will give you a daily notification if there is an event with free food that day. Is that ok?";
            [UIView animateWithDuration:0.5f animations:^{
                [self.headerLabel setAlpha:1.0f];
                [self.descriptionLabel setAlpha:1.0f];
                [self.yesButton setAlpha:1.0f];
                [self.noButton setAlpha:1.0f];
            } completion:^(BOOL finished) {
            }];
        }];
    }
}
         
#pragma mark - Backend Helper Methods

-(void)loginUser:(int)answer{
    // Get user location
    double latitude = locationManager.location.coordinate.latitude;
    double longitude = locationManager.location.coordinate.longitude;
   
    NSDictionary *userData = @{@"latitude":[NSString stringWithFormat:@"%f",latitude],@"longitude":[NSString stringWithFormat:@"%f",longitude],@"name":name,@"userId":userId,@"school":school};
     NSLog(@"%@",userData);
    [backendClass loginWithUserLocation:userData withCompletionHandler:^(BOOL result, NSString *error) {
        if(result){
            // Go to app: unwind segue
            dispatch_async(dispatch_get_main_queue(), ^{
                if(answer == 1){
                    // Register for Push Notitications
                    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                                    UIUserNotificationTypeBadge |
                                                                    UIUserNotificationTypeSound);
                    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                             categories:nil];
                    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                }
                [progressHUD hide];
                [self performSegueWithIdentifier:@"toApp" sender:self];
            });
            
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [progressHUD hide];
                // Show connection error.
                UIAlertController *alertController = [UIAlertController
                                                      alertControllerWithTitle:@"Error"
                                                      message:@"No connection!"
                                                      preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction
                                           actionWithTitle:NSLocalizedString(@"Ok", @"OK action")
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action)
                                           {
                                               [alertController removeFromParentViewController];
                                           }];
                [alertController addAction:okAction];
                [self presentViewController:alertController animated:YES completion:nil];
            });
        }
    }];
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
