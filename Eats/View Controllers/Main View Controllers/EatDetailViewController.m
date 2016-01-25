//
//  EatDetailViewController.m
//  Eats
//
//  Created by Robert Cash on 11/21/15.
//  Copyright © 2015 Robert Cash. All rights reserved.
//

#import "EatDetailViewController.h"

@interface EatDetailViewController ()
// Detail Labels
@property (weak, nonatomic) IBOutlet UILabel *foodLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

// Detail Buttons
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

// Poll Labels
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UILabel *yesCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *noCountLabel;

// Poll Buttons
@property (weak, nonatomic) IBOutlet UIButton *yesButton;
@property (weak, nonatomic) IBOutlet UIButton *noButton;

// Other Buttons
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@end

@implementation EatDetailViewController{
    // Data
    BackendClass *backendClass;
    UserCache *userCache;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpData];
    [self setUpUI];
}

-(void)viewWillAppear:(BOOL)animated{
    // Set up navigation Bar
    [self setUpNavigationBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup Methods

-(void)setUpData{
    userCache = [[UserCache alloc]init];
    backendClass = [[BackendClass alloc]init];
    
}

-(void)setUpUI{
    // Detail labels
    self.foodLabel.text = self.nom.food;
    self.locationLabel.text = self.nom.location;
    self.timeLabel.text = [self dateToString];
    
    // Detail Buttons
    self.saveButton.layer.cornerRadius = 5;
    self.saveButton.clipsToBounds = YES;
    [[self.saveButton layer] setBorderWidth:1.0f];
    [[self.saveButton layer] setBorderColor:[UIColor colorWithRed:204/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1].CGColor];
    if(self.nom.isSaved){
        [self savedNom];
    }
    self.shareButton.layer.cornerRadius = 5;
    self.shareButton.clipsToBounds = YES;
    [[self.shareButton layer] setBorderWidth:1.0f];
    [[self.shareButton layer] setBorderColor:[UIColor colorWithRed:204/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1].CGColor];
    
    // Poll Question Label
    self.questionLabel.text = self.nom.question;
    
    // Poll Buttons
    self.yesButton.layer.cornerRadius = 5;
    self.yesButton.clipsToBounds = YES;
    [[self.yesButton layer] setBorderWidth:1.0f];
    [[self.yesButton layer] setBorderColor:[UIColor colorWithRed:204/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1].CGColor];
    self.noButton.layer.cornerRadius = 5;
    self.noButton.clipsToBounds = YES;
    [[self.noButton layer] setBorderWidth:1.0f];
    [[self.noButton layer] setBorderColor:[UIColor colorWithRed:204/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1].CGColor];
    NSDictionary *vote = @{@"question":@"",@"vote":@""};
    
    if([[NSDate date] timeIntervalSince1970] < [self.nom.time timeIntervalSince1970]){
        self.yesCountLabel.text = [self.nom.yesCountOne stringValue];
        self.noCountLabel.text = [self.nom.noCountOne stringValue];
        if([self.nom.voteResultPollOne isEqualToString:@"yes"] || ([vote[@"question"] isEqualToString:@"one"] && [vote[@"vote"]isEqualToString:@"yes"])){
            [self votedYes];
        }
        if([self.nom.voteResultPollOne isEqualToString:@"no"] || ([vote[@"question"] isEqualToString:@"one"] && [vote[@"vote"]isEqualToString:@"no"])){
            [self votedNo];
        }
    }
    if([[NSDate date]timeIntervalSince1970] >= [self.nom.time timeIntervalSince1970]){
        self.yesCountLabel.text = [self.nom.yesCountTwo stringValue];
        self.noCountLabel.text = [self.nom.noCountTwo stringValue];
        if([self.nom.voteResultPollTwo isEqualToString:@"yes"] || ([vote[@"question"] isEqualToString:@"two"] && [vote[@"vote"]isEqualToString:@"yes"])){
            [self votedYes];
        }
        if([self.nom.voteResultPollTwo isEqualToString:@"no"] || ([vote[@"question"] isEqualToString:@"two"] && [vote[@"vote"]isEqualToString:@"no"])){
            [self votedNo];
        }
    }
    
    // Delete Button
    NSLog(@"%@",self.nom.nomAuthorID);
    if(![[userCache getUserId] isEqual:self.nom.nomAuthorID]){
        self.deleteButton.enabled = NO;
        [self.deleteButton setTintColor:[UIColor clearColor]];
    }
    
}

-(void)setUpNavigationBar{
    self.navigationItem.title = self.nom.food;
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,
      [UIFont fontWithName:@"Gotham-Medium" size:20.0],
      NSFontAttributeName, nil]];
}

#pragma mark - UI Helper Methods

-(NSString *)dateToString{
    if([self.nom.time timeIntervalSince1970] <= [[NSDate date]timeIntervalSince1970]){
        return @"Now";
    }
    else{
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.doesRelativeDateFormatting = YES;
        [formatter setDateStyle:NSDateFormatterFullStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        return [formatter stringFromDate:self.nom.time];
    }
}

-(void)savedNom{
    [self.saveButton setTitle:@"Nom Saved" forState:UIControlStateNormal];
    [self.saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.saveButton setBackgroundColor:[UIColor colorWithRed:72/255.0 green:179.0/255.0 blue:132.0/255.0 alpha:1]];
}

-(void)unsavedNom{
    [self.saveButton setTitle:@"Save Nom" forState:UIControlStateNormal];
    [self.saveButton setTitleColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.saveButton setBackgroundColor:[UIColor whiteColor]];
}

-(void)votedYes{
    [self.yesButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.yesButton setBackgroundColor:[UIColor colorWithRed:72/255.0 green:179.0/255.0 blue:132.0/255.0 alpha:1]];
    self.yesButton.enabled = NO;
    self.noButton.enabled = NO;
}

-(void)unvoteYes{
    [self.yesButton setTitleColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.yesButton setBackgroundColor:[UIColor whiteColor]];
    self.yesButton.enabled = YES;
    self.noButton.enabled = YES;
}

-(void)votedNo{
    [self.noButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.noButton setBackgroundColor:[UIColor colorWithRed:72/255.0 green:179.0/255.0 blue:132.0/255.0 alpha:1]];
    self.yesButton.enabled = NO;
    self.noButton.enabled = NO;
}

-(void)unvoteNo{
    [self.noButton setTitleColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.noButton setBackgroundColor:[UIColor whiteColor]];
    self.yesButton.enabled = YES;
    self.noButton.enabled = YES;
}



-(void)incrementCount:(int)field{
    if(field == 0){
        [UIView animateWithDuration:0.5f animations:^{
            [self.yesCountLabel setAlpha:0.0f];
        } completion:^(BOOL finished) {
            if([[NSDate date] timeIntervalSince1970] < [self.nom.time timeIntervalSince1970]){
                self.nom.yesCountOne = [NSNumber numberWithInt:[self.nom.yesCountOne intValue] + 1];
                self.yesCountLabel.text = [self.nom.yesCountOne stringValue];
            }
            if([[NSDate date]timeIntervalSince1970] >= [self.nom.time timeIntervalSince1970]){
                self.nom.yesCountTwo = [NSNumber numberWithInt:[self.nom.yesCountTwo intValue] + 1];
                self.yesCountLabel.text = [self.nom.yesCountTwo stringValue];
            }
            [UIView animateWithDuration:0.5f animations:^{
                [self.yesCountLabel setAlpha:1.0f];
            } completion:^(BOOL finished) {
            }];
        }];
    }
    else{
        [UIView animateWithDuration:0.5f animations:^{
            [self.noCountLabel setAlpha:0.0f];
        } completion:^(BOOL finished) {
            if([[NSDate date] timeIntervalSince1970] < [self.nom.time timeIntervalSince1970]){
                self.nom.noCountOne = [NSNumber numberWithInt:[self.nom.noCountOne intValue] + 1];
                self.noCountLabel.text = [self.nom.noCountOne stringValue];
            }
            if([[NSDate date]timeIntervalSince1970] >= [self.nom.time timeIntervalSince1970]){
                self.nom.noCountTwo = [NSNumber numberWithInt:[self.nom.noCountTwo intValue] + 1];
                self.noCountLabel.text = [self.nom.noCountTwo stringValue];
            }
            [UIView animateWithDuration:0.5f animations:^{
                [self.noCountLabel setAlpha:1.0f];
            } completion:^(BOOL finished) {
            }];
        }];
    }
}

-(void)decrementCount:(int)field{
    if(field == 0){
        [UIView animateWithDuration:0.5f animations:^{
            [self.yesCountLabel setAlpha:0.0f];
        } completion:^(BOOL finished) {
            if([[NSDate date] timeIntervalSince1970] < [self.nom.time timeIntervalSince1970]){
                self.nom.yesCountOne = [NSNumber numberWithInt:[self.nom.yesCountOne intValue] - 1];
                self.yesCountLabel.text = [self.nom.yesCountOne stringValue];
            }
            if([[NSDate date]timeIntervalSince1970] >= [self.nom.time timeIntervalSince1970]){
                self.nom.yesCountTwo = [NSNumber numberWithInt:[self.nom.yesCountTwo intValue] - 1];
                self.yesCountLabel.text = [self.nom.yesCountTwo stringValue];
            }
            [UIView animateWithDuration:0.5f animations:^{
                [self.yesCountLabel setAlpha:1.0f];
            } completion:^(BOOL finished) {
            }];
        }];
    }
    else{
        [UIView animateWithDuration:0.5f animations:^{
            [self.noCountLabel setAlpha:0.0f];
        } completion:^(BOOL finished) {
            if([[NSDate date] timeIntervalSince1970] < [self.nom.time timeIntervalSince1970]){
                self.nom.noCountOne = [NSNumber numberWithInt:[self.nom.noCountOne intValue] - 1];
                self.noCountLabel.text = [self.nom.noCountOne stringValue];
            }
            if([[NSDate date]timeIntervalSince1970] >= [self.nom.time timeIntervalSince1970]){
                self.nom.noCountTwo = [NSNumber numberWithInt:[self.nom.noCountTwo intValue] - 1];
                self.noCountLabel.text = [self.nom.noCountTwo stringValue];
            }
            [UIView animateWithDuration:0.5f animations:^{
                [self.noCountLabel setAlpha:1.0f];
            } completion:^(BOOL finished) {
            }];
        }];
    }
}

#pragma mark - IB Action Code

- (IBAction)save:(id)sender {
    if(!self.nom.isSaved){
        [self savedNom];
        [backendClass saveNom:self.nom withCompletionHandler:^(BOOL result, NSString *error) {
        
        if(result){
            self.nom.isSaved = YES;
        }
        else{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:error preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            }]];
            [self presentViewController:alert animated:YES completion:nil];
            [self unsavedNom];
        }
        }];
    }
    else{
        [self unsavedNom];
        [backendClass unsaveNom:self.nom withCompletionHandler:^(BOOL result, NSString *error) {
            
            if(result){
                self.nom.isSaved = NO;
            }
            else{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:error preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                }]];
                [self presentViewController:alert animated:YES completion:nil];
                [self savedNom];
            }
        }];
    }
}

- (IBAction)share:(id)sender {
    // Share setup and init
    NSString *textToShare = [NSString stringWithFormat:@"Free food found at %@ on Noms: %@ at %@! %@",[userCache getEducation],self.nom.food,self.nom.location,@"http://apple.co/1Z6viGt"];
    NSArray *activityItems = @[textToShare];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypeMail];
    [self presentViewController:activityVC animated:TRUE completion:nil];
}

- (IBAction)yes:(id)sender {
    [self votedYes];
    [self incrementCount:0];
    [backendClass voteOnNom:@"yes" nom:self.nom withCompletionHandler:^(BOOL result, NSString *error) {
        
        if(result){
            NSString *question = @"";
            if([[NSDate date] timeIntervalSince1970] < [self.nom.time timeIntervalSince1970]){
                question = @"one";
            }
            else{
                question = @"two";
            }
        }
        else{
            [self unvoteYes];
            [self decrementCount:0];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:error preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}

- (IBAction)no:(id)sender {
    [self votedNo];
    [self incrementCount:1];
    [backendClass voteOnNom:@"no" nom:self.nom withCompletionHandler:^(BOOL result, NSString *error) {
        if(result){
            NSString *question = @"";
            if([[NSDate date] timeIntervalSince1970] < [self.nom.time timeIntervalSince1970]){
                question = @"one";
            }
            else{
                question = @"two";
            }
        }
        else{
            [self unvoteNo];
            [self decrementCount:1];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:error preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];

}

- (IBAction)delete:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete nom?" message:@"Are you sure you want to delete this nom?" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:nil]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action){
        [backendClass deleteNom:self.nom withCompletionHandler:^(BOOL result, NSString *error) {
            if(result){
                [self performSegueWithIdentifier:@"backToEats" sender:self];
            }
            else{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:error preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                }]];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }];
    }]];
    
    
    [self presentViewController:alert animated:YES completion:nil];
    

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
