//
//  SplashViewController.m
//  Eats
//
//  Created by Robert Cash on 11/20/15.
//  Copyright © 2015 Robert Cash. All rights reserved.
//

#import "UserCache.h"
#import "PBJVideoView.h"
#import "PBJVideoPlayerController.h"
#import "SplashViewController.h"

@interface SplashViewController ()<PBJVideoPlayerControllerDelegate>
{
    // Data
    UserCache *userCache;
    //UI
    PBJVideoPlayerController *videoPlayerController;
}

@property (weak, nonatomic) IBOutlet UILabel *eatsLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@end

@implementation SplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpUI];
    [self setUpData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setUpUI{
    // allocate video controller
    videoPlayerController = [[PBJVideoPlayerController alloc] init];
    videoPlayerController.delegate = self;
    videoPlayerController.view.frame = self.view.bounds;
    [videoPlayerController setVideoFillMode:@"AVLayerVideoGravityResizeAspectFill"];
    
    // setup media
    NSURL *myURL =[[NSBundle mainBundle] URLForResource:@"Baking_Cookies_Alt" withExtension:@"mp4"];
    videoPlayerController.videoPath = [myURL absoluteString];
    
    // present
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
    // Setup Button
    self.startButton.layer.cornerRadius = 5;
    self.startButton.clipsToBounds = YES;
    [[self.startButton layer] setBorderWidth:3.0f];
    [[self.startButton layer] setBorderColor:[UIColor whiteColor].CGColor];
    
}

-(void)setUpData{
    userCache = [[UserCache alloc]init];
    [userCache clearAllData];    
}

-(void)addUIToView{
    [self.view addSubview:self.eatsLabel];
    [self.view addSubview:self.descriptionLabel];
    [self.view addSubview:self.startButton];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
