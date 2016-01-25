//
//  EatsViewController.m
//  Eats
//
//  Created by Robert Cash on 11/21/15.
//  Copyright © 2015 Robert Cash. All rights reserved.
//  http://codewithchris.com/iad-tutorial/

#import "EatsViewController.h"

@interface EatsViewController ()<UITabBarControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property UILabel *errorLabel;

@end

@implementation EatsViewController{
    // Data Stuff
    BackendClass *backendClass;
    BackendClass *backgroundBackendClass;
    UserCache *userCache;
    NSArray *sections;
    Nom *selectedNom;
    
    // UI
    ProgressHUD *progressHUD;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpUI];
    [self setUpData];
    self.addButton.enabled = NO;
    [progressHUD show];
    
     
}

-(void)viewDidAppear:(BOOL)animated{
    if([userCache getUserId] == NULL){
        [progressHUD hide];
        [self performSegueWithIdentifier:@"toLogin" sender:self];
    }
    else{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self getData];
        });
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self backgroundTasks];
        });
    }
    self.tabBarController.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated{
    // Set up navigation Bar
    [self navigationBarSetup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup Methods

-(void)setUpData{
    backendClass = [[BackendClass alloc]init];
    userCache = [[UserCache alloc]init];
}

-(void)setUpUI{
    // Navigation bar
    [self navigationBarSetup];
    
    // Table View
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor  = [UIColor whiteColor];
    self.refreshControl.backgroundColor = [UIColor colorWithRed:72/255.0 green:179.0/255.0 blue:132.0/255.0 alpha:1];
    [self.refreshControl addTarget:self
                            action:@selector(getData)
                  forControlEvents:UIControlEventValueChanged];
    [self.view updateConstraints];
    
    // Progress HUD
    progressHUD = [[ProgressHUD alloc]init];
}

- (void)scrollToTop
{
    UITableView *tableView = self.tableView;
    UIEdgeInsets tableInset = tableView.contentInset;
    [tableView setContentOffset:CGPointMake(- tableInset.left, - tableInset.top)
                       animated:YES];
}

-(void)navigationBarSetup{
    self.navigationItem.title = @"Noms";
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,
      [UIFont fontWithName:@"BELLABOO-Regular" size:29.0],
      NSFontAttributeName, nil]];
}

- (void)tabBarController:(UITabBarController *)tabBarController
 didSelectViewController:(UIViewController *)viewController
{
    [self scrollToTop];
}

#pragma mark - API Methods

-(void)getData{
    [backendClass getNoms:^(NSDictionary *noms, NSArray* nomsSections, NSString *error) {
        if(![error isEqualToString:@""]){
            dispatch_async(dispatch_get_main_queue(), ^{
                self.nomsData = [[NSDictionary alloc]init];
                sections = [[NSArray alloc]init];
                self.refreshControl.tintColor  = [UIColor whiteColor];
                self.refreshControl.backgroundColor = [UIColor colorWithRed:72/255.0 green:179.0/255.0 blue:132.0/255.0 alpha:1];
            });
            [self tableViewMessageHelper:error];
        }
        else{
            if([noms count] == 0){
                // No Noms
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.nomsData = noms;
                    sections = nomsSections;
                    self.refreshControl.tintColor  = [UIColor whiteColor];
                    self.refreshControl.backgroundColor = [UIColor colorWithRed:72/255.0 green:179.0/255.0 blue:132.0/255.0 alpha:1];
                });
                [self tableViewMessageHelper:@"No Noms!"];
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.nomsData = noms;
                    sections = nomsSections;
                    self.refreshControl.tintColor  = [UIColor colorWithRed:72/255.0 green:179.0/255.0 blue:132.0/255.0 alpha:1];
                    self.refreshControl.backgroundColor = [UIColor whiteColor];
                });
                [self tableViewMessageHelper:@""];
            }
        }
    }];
}

-(void)backgroundTasks{
    backgroundBackendClass = [[BackendClass alloc]init];
    [self sendFacebookEventData];
    [self getNotifications];
}

-(void)sendFacebookEventData{
    [backgroundBackendClass sendFacebookEvents];
}

-(void)getNotifications{
    [backgroundBackendClass getNotifications:^(NSNumber *notifcations, NSString *error) {
        if([error isEqualToString:@""]){
            dispatch_async(dispatch_get_main_queue(), ^{
                if(notifcations.intValue != 0){
                    [[self.tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:notifcations.stringValue];
                }
                else{
                    [[self.tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:nil];
                }
            });
        }
    }];
}

# pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.nomsData[sections[section]]count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return sections[section];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 4, tableView.frame.size.width, 18)];
    label.textColor = [UIColor whiteColor];
    [view setOpaque:YES];
    [label setFont:[UIFont fontWithName:@"Gotham-Book" size:15.0]];
    NSString *string = sections[section];
    [label setText:string];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorWithRed:72/255.0 green:179.0/255.0 blue:132.0/255.0 alpha:1]];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EatsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"nom" forIndexPath:indexPath];
    
    // Nom to Table Cell
    Nom *nom = self.nomsData[sections[indexPath.section]][indexPath.row];
    cell.foodNameLabel.text = nom.food;
    cell.locationLabel.text = nom.location;
    cell.timeLabel.text = [self dateToTime:nom];
    cell.monthLabel.text = [self dateToMonth:nom];
    cell.dateLabel.text = [self dateToDateString:nom];
    cell.blackView.layer.cornerRadius = 5;
    cell.blackView.clipsToBounds = YES;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selectedNom = self.nomsData[sections[indexPath.section]][indexPath.row];
    NSLog(@"%@",selectedNom);
    if(selectedNom.isFacebookEvent){
        [self performSegueWithIdentifier:@"toFacebookNom" sender:self];
    }else{
        [self performSegueWithIdentifier:@"toDetails" sender:self];
    }
}

#pragma mark - Table View Helper Methods

-(void)tableViewMessageHelper:(NSString *) message{
    dispatch_async(dispatch_get_main_queue(), ^{
        // Create Message Label
        if(!self.tableView.backgroundView){
            self.errorLabel = nil;
            self.tableView.backgroundView = nil;
            self.errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
            self.errorLabel.textColor = [UIColor colorWithRed:72/255.0 green:179.0/255.0 blue:132.0/255.0 alpha:1];
            self.errorLabel.numberOfLines = 0;
            self.errorLabel.textAlignment = NSTextAlignmentCenter;
            self.errorLabel.font = [UIFont fontWithName:@"Gotham-Medium" size:25];
            [self.errorLabel sizeToFit];
            self.tableView.backgroundView = self.errorLabel;
        }
        // Add Button Re-enable
        self.addButton.enabled = YES;
        // Stop Refresh Control
        [self.refreshControl endRefreshing];
        // Hide Progress HUD
        [progressHUD hide];
        // Reload Table View
        [self.tableView reloadData];
        // Set Message
        self.errorLabel.text = message;
    });
}

#pragma mark - Table View UI Helper Methods

-(NSString *)dateToTime:(Nom *)nom{
    if([nom.time timeIntervalSince1970] <= [[NSDate date]timeIntervalSince1970]){
        return @"Now";
    }
    else{
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        return [formatter stringFromDate:nom.time];
    }
}

-(NSString *)dateToMonth:(Nom *)nom{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger monthNumber = [calendar component:NSCalendarUnitMonth fromDate:nom.time];
    NSString *month = @"";
    
    switch (monthNumber){
        case 1:
            month = @"JAN";
            break;
        case 2:
            month = @"FEB";
            break;
        case 3:
            month = @"MAR";
            break;
        case 4:
            month = @"APR";
            break;
        case 5:
            month = @"MAY";
            break;
        case 6:
            month = @"JUN";
            break;
        case 7:
            month = @"JUL";
            break;
        case 8:
            month = @"AUG";
            break;
        case 9:
            month = @"SEP";
            break;
        case 10:
            month = @"OCT";
            break;
        case 11:
            month = @"NOV";
            break;
        case 12:
            month = @"DEC";
            break;
    }
    return month;
}

-(NSString *)dateToDateString:(Nom *)nom{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger day = [calendar component:NSCalendarUnitDay fromDate:nom.time];
    return [NSString stringWithFormat:@"%ld",(long)day];
}

#pragma mark - IB Action Methods

- (IBAction)share:(id)sender {
    // Share setup and init
    NSString *textToShare;
    if(![[userCache getEducation] isEqualToString:@"none"]){
        textToShare = [NSString stringWithFormat:@"Find free food at %@ with Noms (%@)! Tweet @nomsfreefood to get your university on Noms!",[userCache getEducation],@"http://apple.co/1Z6viGt"];
    }
    else{
        textToShare = [NSString stringWithFormat:@"Find free food on your campus with Noms (%@)! Tweet @nomsapp to get your university on Noms!",@"http://apple.co/1Z6viGt"];
    }
    NSArray *activityItems = @[textToShare];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypeMail];
    [self presentViewController:activityVC animated:TRUE completion:nil];
}

- (IBAction)createNom:(id)sender {
    if(![[userCache getEducation] isEqualToString:@"none"]){
        [self performSegueWithIdentifier:@"toCreate" sender:self];
    }
    else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Hey!" message:@"You are not at a supported campus and can't post a nom! Tweet us at @nomsfreefood to get your university on Noms!" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}



#pragma mark - Navigation

- (IBAction)unwindEats:(UIStoryboardSegue *)unwindSegue
{
    
}

- (IBAction)unwindNewEats:(UIStoryboardSegue *)unwindSegue
{
    [progressHUD show];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"toDetails"]){
        EatDetailViewController *controller = [segue destinationViewController];
        controller.nom = selectedNom;
        self.navigationItem.title = @"";
    }
    if([segue.identifier isEqualToString:@"toFacebookNom"]){
        EatDetailDescriptionViewController *controller = [segue destinationViewController];
        controller.nom = selectedNom;
        self.navigationItem.title = @"";
    }
}


@end
