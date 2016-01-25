//
//  YourNomsViewController.m
//  Eats
//
//  Created by Robert Cash on 12/23/15.
//  Copyright © 2015 Robert Cash. All rights reserved.
//

#import "YourNomsViewController.h"

@interface YourNomsViewController ()<UITabBarControllerDelegate>

@property UILabel *errorLabel;

@end

@implementation YourNomsViewController{
    // Data
    BackendClass *backendClass;
    BackendClass *backgroundBackendClass;
    NSArray *sections;
    Nom *selectedNom;
}

#pragma mark - View Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
}

-(void)viewDidAppear:(BOOL)animated{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self getData];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self backgroundTasks];
    });
    
    self.tabBarController.delegate = self;
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
    
    // Table View
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)scrollToTop
{
    UITableView *tableView = self.tableView;
    UIEdgeInsets tableInset = tableView.contentInset;
    [tableView setContentOffset:CGPointMake(- tableInset.left, - tableInset.top)
                       animated:YES];
}

#pragma mark - UI Helper Methods

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
        // Reload Table View
        [self.tableView reloadData];
        // Set Message
        self.errorLabel.text = message;
    });
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    [self scrollToTop];
    
    return YES;
}

#pragma mark - API Methods

-(void)getData{
    backendClass = [[BackendClass alloc]init];
    [backendClass getYourNoms:^(NSDictionary *yourNoms, NSArray* yourNomsSections, NSString *error) {
        if(![error isEqualToString:@""]){
            dispatch_async(dispatch_get_main_queue(), ^{
                self.yourNomsData = [[NSDictionary alloc]init];
                sections = [[NSArray alloc]init];
            });
            [self tableViewMessageHelper:error];
        }
        else{
            if([yourNoms count] == 0){
                // No Noms
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.yourNomsData = yourNoms;
                    sections = yourNomsSections;
                });
                [self tableViewMessageHelper:@"No Noms!"];
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.yourNomsData = yourNoms;
                    sections = yourNomsSections;
                });
                [self tableViewMessageHelper:@""];
            }
        }
    }];
}

-(void)backgroundTasks{
    backgroundBackendClass = [[BackendClass alloc]init];
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

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.yourNomsData[sections[section]]count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return sections[section];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EatsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"nom" forIndexPath:indexPath];
    
    // Nom to Table Cell
    Nom *nom = self.yourNomsData[sections[indexPath.section]][indexPath.row];
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
    selectedNom = self.yourNomsData[sections[indexPath.section]][indexPath.row];
    if(selectedNom.isFacebookEvent){
        [self performSegueWithIdentifier:@"toFacebookNom" sender:self];
    }else{
        [self performSegueWithIdentifier:@"toDetails" sender:self];
    }
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"toDetails"]){
        EatDetailViewController *controller = [segue destinationViewController];
        controller.nom = selectedNom;
    }
    else if([segue.identifier isEqualToString:@"toFacebookNom"]){
        EatDetailDescriptionViewController *controller = [segue destinationViewController];
        controller.nom = selectedNom;
    }
    else{
        self.tabBarController.delegate = nil;
    }
}


@end
