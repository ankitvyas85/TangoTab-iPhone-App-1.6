//
//  ViewController.m
//  TangoTab
//
//  Created by Gopal Krishna U on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "ViewController.h"

@implementation ViewController
@synthesize tabview,userNameTextField,passwordTextField,rememberSwitch,forgetButton,sharedDelegate;
@synthesize logArray,forPasswordViewCtrl;
@synthesize userArray,userDict,currentElement,user_id,first_name,last_name,zip_code,mobile_phone,count_Message,networkQueue;
@synthesize nearMeBarItem,myOfferBarItem,searchBarItem,settingsBarItem,failed,keychain;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}
#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    sharedDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    self.tabview.allowsSelection = NO;
    
    keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"testID" accessGroup:nil];
    if (sharedDelegate.isNotReachable == YES) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"We are unable to make an internet connection at this time. Some functionalities will be limited until a connection is made." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    } 
    
    else { 
        if (([[sharedDelegate.searchingradies objectForKey:@"useremail"]length]!=0 && [[sharedDelegate.searchingradies objectForKey:@"password"] length]!=0) || [[keychain objectForKey:(id)kSecAttrAccount] length]!=0) {
            [self user_validation];
            if ([[userDict valueForKey:@"first_name"] length] == 0) {
                if ([[userDict valueForKey:@"message"]length]!=0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:[userDict valueForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [alert release]; 
                
                }
            }
            else{
                UITabBarController *tab = [self tabBarController];
                [tab setSelectedIndex:1];
                [[self navigationController] pushViewController:tab animated:YES];
            }
        }
    }
    UIBarButtonItem *login = [[UIBarButtonItem alloc] initWithTitle:@"Sign In" style:UIBarButtonItemStyleBordered target:self action:@selector(signin:)];
    
    [self.navigationItem setRightBarButtonItem:login];
    
    UIBarButtonItem *signin = [[UIBarButtonItem alloc] initWithTitle:@"Sign Up" style:UIBarButtonItemStyleBordered target:self action:@selector(signup:)];
    
    [self.navigationItem setLeftBarButtonItem:signin];
    
    logArray = [[NSArray alloc] initWithObjects:@"Email",@"Password",@"Keep me signed-in",@"",nil];
    
    userNameTextField = [[UITextField  alloc ] initWithFrame: CGRectMake(120, 8, 180, 31) ];
    [userNameTextField setPlaceholder:@"Enter Email"];
    [userNameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [userNameTextField setBorderStyle:UITextBorderStyleBezel];
    [userNameTextField setSecureTextEntry:NO];
    [userNameTextField setKeyboardType:UIKeyboardTypeEmailAddress];
    [userNameTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [userNameTextField setReturnKeyType:UIReturnKeyNext];
    [userNameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [userNameTextField addTarget:self action:@selector(userNameTextFieldNextClickedClicked:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    passwordTextField = [[ UITextField alloc ] initWithFrame: CGRectMake(120, 8, 180, 31) ];
    [passwordTextField setPlaceholder:@"Enter Password"];
    [passwordTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [passwordTextField setBorderStyle:UITextBorderStyleBezel];
    [passwordTextField setSecureTextEntry:YES];
    [passwordTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [passwordTextField setReturnKeyType:UIReturnKeyGo];
    [passwordTextField addTarget:self action:@selector(signin:) forControlEvents:UIControlEventEditingDidEndOnExit];
   
    rememberSwitch=[[UISwitch alloc]initWithFrame:CGRectMake(200, 8, 79, 21)];
    [rememberSwitch setOn:YES];
    [rememberSwitch addTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventValueChanged];
    
    UIImage *forimage = [UIImage imageNamed:@"forgotpassword_btn.png"];
    
    forgetButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 7,forimage.size.width,forimage.size.height)];
    [forgetButton setImage:forimage forState:UIControlStateNormal];
    [forgetButton setHidden:NO];
    [forgetButton setTag:13];
    [forgetButton addTarget:self action:@selector(forgetButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)viewWillAppear:(BOOL)animated{
    rememberSwitch.on=YES;
    [userNameTextField becomeFirstResponder];
    [passwordTextField resignFirstResponder];
    [super viewWillAppear:YES];
}

-(void)forgetButtonClicked:(id)sender {
    
    forPasswordViewCtrl = [[ForgetPasswordViewController alloc] initWithNibName:@"ForgetPasswordViewController" bundle:[NSBundle mainBundle]];
    
    [self presentModalViewController:forPasswordViewCtrl animated:YES];
}
-(IBAction)signup :(id)sender {

    SignUpViewController *singUpVCtrl = [[SignUpViewController alloc] initWithNibName:@"SignUpViewController" bundle:[NSBundle mainBundle]];
    singUpVCtrl.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:singUpVCtrl animated:YES];
}

-(IBAction) signin :(id)sender {
    [userNameTextField becomeFirstResponder];
    [passwordTextField becomeFirstResponder];
    if (sharedDelegate.isNotReachable == YES) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"We are unable to make an internet connection at this time. Some functionalities will be limited until a connection is made." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    else {
        if ([userNameTextField.text length] ==0 || [passwordTextField.text length] ==0)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:@"Please provide valid Login information" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        else {
            if (rememberSwitch.on) {
                [sharedDelegate.searchingradies setValue:@"YES" forKey:@"rememberSwitch"];
            }
            else{
                [sharedDelegate.searchingradies setValue:@"NO" forKey:@"rememberSwitch"];
            }
                [self user_validation];
            if ([[userDict valueForKey:@"first_name"] length] == 0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TangoTab" message:[userDict valueForKey:@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [alert release]; 
            }
            else {
                NSError *error = nil;
                if (![[GANTracker sharedTracker] trackEvent:@"Sign In Button"
                                                     action:@"TrackEvent"
                                                      label:@"Sign In"
                                                      value:-1
                                                  withError:&error]) {
                    NSLog(@"Error Occured");
                }
                
                if (sharedDelegate.isSignout==YES) {
                    sharedDelegate.isSignout=NO;
                    UITabBarController *signTab = [self tabBarController];
                    
                    [signTab setSelectedIndex:1];
                    [[self navigationController] pushViewController:signTab animated:YES];
                }
                else {
                    UITabBarController *signTab = [self tabBarController];
                    //sharedDelegate.isSelectedDisButton=YES;
                    [signTab setSelectedIndex:1];
                    [[self navigationController] pushViewController:signTab animated:YES];
                }
            }
        }
    }
}


- (UITabBarController*)tabBarController
{
    MyOffersViewController *myOffersVCtrl = [[MyOffersViewController alloc] initWithNibName:@"MyOffersViewController" bundle:[NSBundle mainBundle]];
    
    UINavigationController *myOfferNavCtrl =  [[UINavigationController alloc] initWithRootViewController:myOffersVCtrl];
    
    myOfferBarItem = [[UITabBarItem alloc] initWithTitle:@"My Offers" image:[UIImage imageNamed:@"MyOffers.png"] tag:100];
    
    [myOfferNavCtrl setTabBarItem:myOfferBarItem];
    NearMeViewController *nearVCtrl = [[NearMeViewController alloc] initWithNibName:@"NearMeViewController" bundle:[NSBundle mainBundle]];
    
   UINavigationController *nearNavCtrl =  [[UINavigationController alloc] initWithRootViewController:nearVCtrl];
    
    nearMeBarItem = [[UITabBarItem alloc] initWithTitle:@"Near Me" image:[UIImage imageNamed:@"NearMe.png"] tag:101];
    
    [nearNavCtrl setTabBarItem:nearMeBarItem];
    
    SearchViewController *searchVCtrl = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:[NSBundle mainBundle]];
    
   UINavigationController *seaNavCtrl =  [[UINavigationController alloc] initWithRootViewController:searchVCtrl];
    
    searchBarItem = [[UITabBarItem alloc] initWithTitle:@"Search" image:[UIImage imageNamed:@"Search.png"] tag:102];
    
    [seaNavCtrl setTabBarItem:searchBarItem];
    
     SettingsViewController *settingsVCtrl = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:[NSBundle mainBundle]];
    
    settingsBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings" image:[UIImage imageNamed:@"Settings.png"] tag:103];
    
    [settingsVCtrl setTabBarItem:settingsBarItem];
    
    UITabBarController *tabController2 = [[UITabBarController alloc] init];
    
    [tabController2 setViewControllers:[NSArray arrayWithObjects:myOfferNavCtrl,nearNavCtrl,seaNavCtrl,settingsVCtrl,nil]];
    
    [myOfferNavCtrl release];
    [myOffersVCtrl release];
    [nearNavCtrl release];
    [nearVCtrl release];
    [searchVCtrl release]; 
    [seaNavCtrl release];
    [settingsVCtrl release];
    return tabController2;
}
- (void) user_validation {
    @try {
        NSString *passwordStringEncoded;
        NSString *passwordString;
        NSString *userName;
        NSData* aData;
        keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"testID" accessGroup:nil];
        if ([userNameTextField.text length]==0) {
            NSString *psw=[keychain objectForKey:(id)kSecValueData];
            aData  = [psw dataUsingEncoding: NSASCIIStringEncoding];
            passwordStringEncoded = [Base64 encode:aData];
            userName   = [keychain objectForKey:(id)kSecAttrAccount];
        } 
        else {
            [keychain setObject:@"" forKey:(id)kSecAttrAccount];
            [keychain setObject:@"" forKey:(id)kSecValueData];  
            [sharedDelegate.searchingradies setValue: @"" forKey:@"useremail"];
            [sharedDelegate.searchingradies setValue:@"" forKey:@"password"];
            [sharedDelegate.searchingradies setValue:@"" forKey:@"firstname"];
            [sharedDelegate.searchingradies setValue:@"" forKey:@"last_name"];
            [sharedDelegate.searchingradies synchronize];
            [sharedDelegate.userdetails setValue:@"" forKey:@"login"];
            [sharedDelegate.userdetails setValue:@"" forKey:@"psw"];
            [sharedDelegate.userdetails synchronize];
            passwordString = [passwordTextField text];
            aData  = [passwordString dataUsingEncoding: NSASCIIStringEncoding];
            passwordStringEncoded = [Base64 encode:aData];
            userName = [userNameTextField text];
        }
        userDict=nil;
        
        NSString *serviceURL = [NSString stringWithFormat:@"%@/uservalidation?emailId=%@&password=%@",SERVER_URL,userName,passwordStringEncoded];	
        NSString *terString = [serviceURL stringByReplacingOccurrencesOfString:@"(null)" withString:@""];

       [self parseXML:terString];
    }
    @catch (NSException *exception) {
        
    }
}

-(void) parseXML:(NSString *) xmlString
{
    userArray = [[NSMutableArray alloc] init];   
    @try {
        NSURL *url = [NSURL URLWithString:[xmlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        NSData *xmlData = [NSData dataWithContentsOfURL:url];
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
        [parser setDelegate:self];
        [parser setShouldProcessNamespaces:NO];
        [parser setShouldReportNamespacePrefixes:NO];
        [parser setShouldResolveExternalEntities:NO];
        [parser parse];
    }
    @catch (NSException *exception) {
    }
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    currentElement=[[NSMutableString alloc]init];
    currentElement=[elementName copy];
    if ([elementName isEqualToString:@"user_details"]) {
        userDict     = [[NSMutableDictionary alloc]init];
        user_id      = [[NSMutableString alloc] init];
        first_name   = [[NSMutableString alloc] init];
        last_name    = [[NSMutableString alloc]init];
        zip_code     = [[NSMutableString alloc]init];
        mobile_phone = [[NSMutableString alloc]init];
    }
    else if ([elementName isEqualToString:@"message"]) {
        userDict     = [[NSMutableDictionary alloc]init];
        user_id      = [[NSMutableString alloc] init];
    }
    else if([elementName isEqualToString:@"success"]){
        count_Message=[[NSMutableString alloc]init];
    }
   
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    
    NSString *terstring = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([currentElement isEqualToString:@"user_id"]) {
        [user_id appendString:terstring];
    }
    else if ([currentElement isEqualToString:@"first_name"]) {
        [first_name appendString:terstring];
    }
    else if ([currentElement isEqualToString:@"last_name"]) {
        [last_name appendString:terstring];
    }
    else if ([currentElement isEqualToString:@"zip_code"]) {
        [zip_code appendString:terstring];
    }
    else if ([currentElement isEqualToString:@"mobile_phone"]) {
        [mobile_phone appendString:terstring];
    }
    else if ([currentElement isEqualToString:@"message"]) {
        [user_id appendFormat:terstring];
    }
    else if([currentElement isEqualToString:@"success"]){
        [count_Message appendFormat:terstring];
    }
}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{   
    if ([elementName isEqualToString:@"user_details"]) {
        [userDict setValue:user_id forKey:@"user_id"];
        [userDict setValue:first_name forKey:@"first_name"];
        [userDict setValue:last_name forKey:@"last_name"];
        [userDict setValue:zip_code forKey:@"zip_code"];
        [userDict setValue:mobile_phone forKey:@"mobile_phone"];
        [userArray addObject:userDict];
    }
    else if ([elementName isEqualToString:@"message"]) {
        [userDict setValue:user_id forKey:@"message"];
        [userArray addObject:userDict];
    }
    else if([elementName isEqualToString:@"success"]){
        [userDict setValue:count_Message forKey:@"count_message"];
        [userArray addObject:userDict];
    }
}

-(void)parserDidEndDocument:(NSXMLParser *)parser{
    keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"testID" accessGroup:nil];
    if ([[userDict objectForKey:@"first_name"]length]!=0) {
        if ([[sharedDelegate.searchingradies objectForKey:@"rememberSwitch"] isEqualToString:@"YES"]) {
            if ([userNameTextField.text length]!=0) {
                
                [keychain setObject:[userNameTextField text] forKey:(id)kSecAttrAccount];
                [keychain setObject:[passwordTextField text] forKey:(id)kSecValueData];    
                NSString * passwordString =[passwordTextField text] ;
                NSData *aData  = [passwordString dataUsingEncoding: NSASCIIStringEncoding];
                NSString *passwordStringEncoded = [Base64 encode:aData];
                [sharedDelegate.searchingradies setValue:userNameTextField.text forKey:@"useremail"];
                [sharedDelegate.searchingradies setValue:passwordStringEncoded forKey:@"password"];
                [sharedDelegate.searchingradies synchronize];
                [sharedDelegate.userdetails setValue:userNameTextField.text forKey:@"login"];
                [sharedDelegate.userdetails setValue:passwordStringEncoded forKey:@"psw"];
                [sharedDelegate.userdetails synchronize];
            }	
            else{
                NSString * passwordString =[keychain objectForKey:(id)kSecValueData] ;
                NSData *aData  = [passwordString dataUsingEncoding: NSASCIIStringEncoding];
                NSString *passwordStringEncoded = [Base64 encode:aData];
                [sharedDelegate.searchingradies setValue: [keychain objectForKey:(id)kSecAttrAccount] forKey:@"useremail"];
                [sharedDelegate.searchingradies setValue:passwordStringEncoded forKey:@"password"];
                [sharedDelegate.searchingradies synchronize];
                [sharedDelegate.userdetails setValue: [keychain objectForKey:(id)kSecAttrAccount] forKey:@"login"];
                [sharedDelegate.userdetails setValue:passwordStringEncoded forKey:@"psw"];
                [sharedDelegate.userdetails synchronize];
            }
            [sharedDelegate.searchingradies setValue:[userDict objectForKey:@"first_name"] forKey:@"firstname"];
            [sharedDelegate.searchingradies setValue:[userDict objectForKey:@"last_name"] forKey:@"last_name"];
            [sharedDelegate.searchingradies synchronize];
        }
        else{
            [sharedDelegate.searchingradies setValue:[userDict objectForKey:@"first_name"] forKey:@"firstname"];
            [sharedDelegate.searchingradies setValue:[userDict objectForKey:@"last_name"] forKey:@"last_name"];
            [sharedDelegate.searchingradies synchronize];
            
            if ([userNameTextField.text length]!=0) {
                NSString * passwordString =[passwordTextField text] ;
                NSData *aData  = [passwordString dataUsingEncoding: NSASCIIStringEncoding];
                NSString *passwordStringEncoded = [Base64 encode:aData];
                [sharedDelegate.userdetails setValue:userNameTextField.text forKey:@"login"];
                [sharedDelegate.userdetails setValue:passwordStringEncoded forKey:@"psw"];
                [sharedDelegate.userdetails synchronize];
                [sharedDelegate.searchingradies setValue:@"YES" forKey:@"rememberSwitch"];
            }
            else{
                NSString * passwordString =[keychain objectForKey:(id)kSecValueData] ;
                NSData *aData  = [passwordString dataUsingEncoding: NSASCIIStringEncoding];
                NSString *passwordStringEncoded = [Base64 encode:aData];
                [sharedDelegate.userdetails setValue: [keychain objectForKey:(id)kSecAttrAccount] forKey:@"login"];
                [sharedDelegate.userdetails setValue:passwordStringEncoded forKey:@"psw"];
                [sharedDelegate.userdetails synchronize];
            }
        }
    }
    else {
        if ([[sharedDelegate.searchingradies objectForKey:@"rememberSwitch"] isEqualToString:@"NO"] ) {
        [keychain setObject:@"" forKey:(id)kSecAttrAccount];
        [keychain setObject:@"" forKey:(id)kSecValueData];  
        [sharedDelegate.searchingradies setValue: @"" forKey:@"useremail"];
        [sharedDelegate.searchingradies setValue:@"" forKey:@"password"];
        [sharedDelegate.searchingradies setValue:@"" forKey:@"firstname"];
        [sharedDelegate.searchingradies setValue:@"" forKey:@"last_name"];
        [sharedDelegate.searchingradies synchronize];
        [sharedDelegate.userdetails setValue:@"" forKey:@"login"];
        [sharedDelegate.userdetails setValue:@"" forKey:@"psw"];
        [sharedDelegate.userdetails synchronize];
        [sharedDelegate.searchingradies setValue:@"YES" forKey:@"rememberSwitch"];
        }
    }
    
    userNameTextField.text=nil;
    passwordTextField.text=nil;
}
-(void)userNameTextFieldNextClickedClicked:(id)sender
{

	[passwordTextField becomeFirstResponder];
}
-(void)passwordTextFieldNextClicked:(id)sender
{
    [passwordTextField becomeFirstResponder];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [logArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellId = @"MYCELL";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellId];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId];
    }
    NSInteger row = [indexPath row];
    
    switch (row) {
        case 0:
            cell.textLabel.text = [logArray objectAtIndex:row];
            [cell addSubview:userNameTextField];
            break;
        case 1:
            cell.textLabel.text = [logArray objectAtIndex:row];
            [cell addSubview:passwordTextField];
            break;
        case 2:
            cell.textLabel.text = [logArray objectAtIndex:row];
            [cell addSubview:rememberSwitch];
            break;
        case 3:
            [forgetButton setImage:[UIImage imageNamed:@"forgotpassword_btn.png"] forState:UIControlStateNormal];
            [cell addSubview:forgetButton];
            break;
        
        default:
            break;
    }

    return cell;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
        
    
}

-(void)dealloc{
    [userNameTextField release];
    [passwordTextField release];
    [logArray release];
    [tabview release];
    [userNameTextField release];
    [passwordTextField release];
    [rememberSwitch release];
    [forgetButton release];
    [userArray release];
    [userDict release];
    [currentElement release];
    [user_id release];
    [first_name release];
    [last_name release];
    [zip_code release];
    [mobile_phone release];
    [sharedDelegate release];
    [forPasswordViewCtrl release];
    
}
@end
