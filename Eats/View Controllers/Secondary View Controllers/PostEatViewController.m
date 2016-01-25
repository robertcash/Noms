//
//  PostEatViewController.m
//  Eats
//
//  Created by Robert Cash on 11/21/15.
//  Copyright © 2015 Robert Cash. All rights reserved.
//

#import "PostEatViewController.h"

@interface PostEatViewController ()<UITextFieldDelegate>

// Buttons
@property (weak, nonatomic) IBOutlet UIBarButtonItem *postButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

// TextFields
@property (weak, nonatomic) IBOutlet UITextField *foodInput;
@property (weak, nonatomic) IBOutlet UITextField *locationInput;

//Other
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property ProgressHUD *progressHUD;

@end

@implementation PostEatViewController{
    // Data
    BackendClass *backendClass;
}

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

#pragma mark Setup Methods

-(void)setUpUI{
    // Navigation bar
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,
      [UIFont fontWithName:@"Gotham-Medium" size:20.0],
      NSFontAttributeName, nil]];
    
    // Buttons
    [self disablePostButton];
    [self.cancelButton setTitleTextAttributes:@{
                                              NSFontAttributeName: [UIFont fontWithName:@"Gotham-Book" size:17.5],
                                              NSForegroundColorAttributeName: [UIColor whiteColor]
                                              } forState:UIControlStateNormal];
    // Date Picker
    self.datePicker.minimumDate = [NSDate date];
    
    // Textfields
    self.foodInput.delegate = self;
    self.locationInput.delegate = self;
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.tableView addGestureRecognizer:gestureRecognizer];
    
    // Progress HUD
    self.progressHUD = [[ProgressHUD alloc]init];
}

-(void)setUpData{
    backendClass = [[BackendClass alloc]init];
}

-(void)hideKeyboard{
    [self.foodInput resignFirstResponder];
    [self.locationInput resignFirstResponder];
}

#pragma mark - UI Helper Methods

-(void)disablePostButton{
    self.postButton.enabled = NO;
    [self.postButton setTitleTextAttributes:@{
                                              NSFontAttributeName: [UIFont fontWithName:@"Gotham-Book" size:17.5],
                                              NSForegroundColorAttributeName: [UIColor lightGrayColor]
                                              } forState:UIControlStateNormal];
}

-(void)enablePostButton{
    self.postButton.enabled = YES;
    [self.postButton setTitleTextAttributes:@{
                                              NSFontAttributeName: [UIFont fontWithName:@"Gotham-Book" size:17.5],
                                              NSForegroundColorAttributeName: [UIColor whiteColor]
                                              } forState:UIControlStateNormal];
}

#pragma mark - TextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if(self.foodInput.text.length > 1 && self.locationInput.text.length > 1){
        [self enablePostButton];
    }
    else{
        [self disablePostButton];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if(self.foodInput.text.length > 1 && self.locationInput.text.length > 1){
        [self enablePostButton];
    }
    else{
        [self disablePostButton];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if(self.foodInput.text.length > 1 && self.locationInput.text.length > 1){
        [self enablePostButton];
    }
    else{
        [self disablePostButton];
    }
    return YES;
}

#pragma mark - IB Action Methods

- (IBAction)post:(id)sender {
    // API Call
    [self.progressHUD show];
    [backendClass postNom:@{@"food":self.foodInput.text,@"location":self.locationInput.text,@"date":self.datePicker.date} withCompletionHandler:^(BOOL result, NSString *error) {
        // Hide progress
        [self.progressHUD hide];
        
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
