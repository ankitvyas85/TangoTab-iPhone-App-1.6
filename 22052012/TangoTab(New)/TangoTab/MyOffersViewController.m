//
//  MyOffersViewController.m
//  TangoTab
//
//  Created by Gopal Krishna U on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyOffersViewController.h"
#import "ASIHTTPRequest.h"
#import "Base64.h"
@implementation MyOffersViewController
@synthesize myOfferTableView;
@synthesize deal_name,isconsumershownup,host_manager_emailid,deal_description,deal_restrictions,start_time,end_time,business_name,reserved_time_stamp,address,image_url,noOfdeals,Details,serverURL,deal_id,deal_manager_emailid,con_res_id;
@synthesize myOffersArray;
@synthesize networkQueue,failed;
@synthesize currentElement;
@synthesize appdelegate;
@synthesize activityIndicatorView,customtableviewcell;
@synthesize passwordStringEncoded;
@synthesize nodeals_Lable,map_button;
@synthesize checkView,mapviewcontroller,sharedDelegate;

//Search 
@synthesize myDealsSearchBar;
@synthesize  searchingArray;
@synthesize searching;
@synthesize cMyDealsArray;
@synthesize letUserSelectRow;
@synthesize overlayview;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    sharedDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
     self.title = @"My Offers";
     self.navigationController.navigationBarHidden=YES;
    myOffersArray=[[NSMutableArray alloc]init];
    cMyDealsArray=[[NSMutableArray alloc] init];
    searchingArray=[[NSMutableArray alloc] init];
    
    myOfferTableView.delegate=self;
    myOfferTableView.dataSource=self;
    pageIndex=2;
    myDealsSearchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    searching = NO;
    searching = NO;
    letUserSelectRow = YES;

    myDealsSearchBar.delegate=self;
    nodeals_Lable = [[UILabel alloc] initWithFrame:CGRectMake(5, 100, 320, 50)];
    [nodeals_Lable setText:@"You have not selected any offers. Please search for a offers and reserve it"];
    [nodeals_Lable setNumberOfLines:2];
    [nodeals_Lable setAlpha:0.5];
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden=YES;
    [super viewWillAppear:YES]; 
    myOfferTableView.tableFooterView.hidden=YES;
    
    appdelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    if (appdelegate.myOffersUpdate==NO) {
        if ([myOffersArray count]!=0) {
            [myOffersArray removeAllObjects];
            [myOfferTableView reloadData];
        }
        [nodeals_Lable removeFromSuperview];
        myOfferTableView.tableFooterView.hidden=YES;
        
        serverURL = [[NSString alloc]initWithFormat:@"%@/mydeals/alldeals?emailId=%@&password=%@&noOfdeals=0&pageIndex=0",SERVER_URL,[appdelegate.userdetails objectForKey:@"login"],[appdelegate.userdetails objectForKey:@"psw"]];
        
        NSString *terString = [serverURL stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
        
        NSURL *url = [NSURL URLWithString:[terString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        [self sendASIHTTPRequest:url];
        
        appdelegate.myOffersUpdate=YES;
        pageIndex=2;
    }
    else{
        if ([myOffersArray count]!=0) {
            [myOfferTableView reloadData];
        }
    }
}

-( void) sendASIHTTPRequest:(NSURL*)serverURLs
{
    
    if (networkQueue) {
		[networkQueue cancelAllOperations];
        [networkQueue setDelegate:nil];
	}
	failed = NO;
	[networkQueue reset];
    networkQueue = [[ASINetworkQueue alloc] init];
	[networkQueue setRequestDidFinishSelector:@selector(FetchComplete:)];
	[networkQueue setRequestDidFailSelector:@selector(FetchFailed:)];
	[networkQueue setDelegate:self];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:serverURLs];
    [request setTimeOutSeconds:60];
    [networkQueue addOperation:request];
    [networkQueue go];
    
}

- (void)FetchComplete:(ASIHTTPRequest *)request 
{
    NSString *respose = [request responseString];
    [self parseXML:respose];
}

- (void)FetchFailed:(ASIHTTPRequest *)request
{
    if (!failed) {
        NSError *error = [request error];
        NSString *description =[NSString stringWithString:[[error userInfo] objectForKey:@"NSLocalizedDescription"]];
        if([description isEqualToString:@"Cannot connect to TangoTab service. This might be due to your data connection. If this problem persists, please notify TangoTab at help@tangotab.com."] || [description isEqualToString:@"It appears there is no data connection, please check your settings."])
        {
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Network Error" message:description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
            [alertView show];
        }
        else if (![description isEqualToString:@"The request was cancelled"]) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Error" message:description delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            [alertView release];
            
        }
        failed = YES;
    }
}
-(void) parseXML:(NSString *) xmlString
{
    @try {
        NSData *xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
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
	if ([elementName isEqualToString:@"detail"]) {
        Details=[[NSMutableDictionary alloc]init];
        deal_name=[[NSMutableString alloc]init];
        isconsumershownup=[[NSMutableString alloc]init];
        host_manager_emailid=[[NSMutableString alloc]init];
        deal_description=[[NSMutableString alloc]init];
        deal_restrictions=[[NSMutableString alloc]init];
        start_time=[[NSMutableString alloc]init];
        end_time=[[NSMutableString alloc]init];
        business_name=[[NSMutableString alloc]init];
        reserved_time_stamp=[[NSMutableString alloc]init];
        address=[[NSMutableString alloc]init];
        image_url=[[NSMutableString alloc]init];
        noOfdeals=[[NSMutableString alloc]init];
        deal_restrictions=[[NSMutableString alloc]init];
        deal_manager_emailid=[[NSMutableString alloc]init];
        con_res_id=[[NSMutableString alloc]init];
        deal_id=[[NSMutableString alloc]init];
    }
    
}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{ 
    if ([elementName isEqualToString:@"detail"]) {
        [Details setValue:deal_name forKey:@"deal_name"];
        [Details setValue:isconsumershownup forKey:@"isconsumershownup"];
        [Details setValue:host_manager_emailid forKey:@"host_manager_emailid"];
        [Details setValue:deal_description forKey:@"deal_description"];
        [Details setValue:start_time forKey:@"start_time"];
        [Details setValue:end_time forKey:@"end_time"];
        [Details setValue:business_name forKey:@"business_name"];
        [Details setValue:reserved_time_stamp forKey:@"reserved_time_stamp"];
        [Details setValue:address forKey:@"address"];
        [Details setValue:image_url forKey:@"image_url"];
        [Details setValue:noOfdeals forKey:@"noOfdeals"];
        [Details setValue:deal_id forKey:@"deal_id"];
        [Details setValue:deal_restrictions forKey:@"deal_restrictions"];
        [Details setValue:deal_manager_emailid forKey:@"deal_manager_emailid"];
        [Details setValue:con_res_id forKey:@"con_res_id"];
        [myOffersArray addObject:Details];
    }
   
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    
    NSString *terstring = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([currentElement isEqualToString:@"deal_name"]) {
        [deal_name appendString:terstring];
    }
    if ([currentElement isEqualToString:@"isconsumershownup"]) {
        [isconsumershownup appendString:terstring];
    }
    if ([currentElement isEqualToString:@"host_manager_emailid"]) {
        [host_manager_emailid appendString:terstring];
    }
    if ([currentElement isEqualToString:@"deal_description"]) {
        [deal_description appendString:terstring];
    }
    if ([currentElement isEqualToString:@"start_time"]) {
        [start_time appendString:terstring];
    }
    if ([currentElement isEqualToString:@"end_time"]) {
        [end_time appendString:terstring];
    }
    if ([currentElement isEqualToString:@"business_name"]) {
        [business_name appendString:terstring];
    }
    if ([currentElement isEqualToString:@"reserved_time_stamp"]) {
        [reserved_time_stamp appendString:terstring];
    }
    if ([currentElement isEqualToString:@"address"]) {
        [address appendString:terstring];
    }
    if ([currentElement isEqualToString:@"image_url"]) {
        [image_url appendString:terstring];
    }
    if ([currentElement isEqualToString:@"noOfdeals"]) {
        [noOfdeals appendString:terstring];
    }
    if ([currentElement isEqualToString:@"deal_id"]) {
        [deal_id appendString:terstring];
    }
    if ([currentElement isEqualToString:@"deal_restrictions"]) {
        [deal_restrictions appendString:terstring];
    }
    if ([currentElement isEqualToString:@"deal_manager_emailid"]) {
        [deal_manager_emailid appendString:terstring];
    }
    if ([currentElement isEqualToString:@"con_res_id"]) {
        [con_res_id appendString:terstring];
    }
}

-(void)parserDidEndDocument:(NSXMLParser *)parser{
    [self stopActivityIndicatorView];
    if ([myOffersArray count]>0) {
        [nodeals_Lable removeFromSuperview];
        [myOfferTableView reloadData];
        map_button.enabled=YES;
    }
    else{
        [nodeals_Lable setText:@"You have not selected any offers. Please search for a offers and reserve it"];
        [self.view addSubview:nodeals_Lable];
         map_button.enabled=NO;
    }
}
- (void)showActivityIndicatorView {
	
	NSArray *subviews = [NSArray arrayWithArray:[self.view subviews]];
	if(![subviews containsObject:activityIndicatorView])
	{
		if (activityIndicatorView) {
			[activityIndicatorView release];
			activityIndicatorView = nil;
		}
		activityIndicatorView = [[ActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
		[activityIndicatorView adjustFrame:CGRectMake(0,0, 320, 480)];
		[self.view addSubview:activityIndicatorView];
	}
}

-(void)stopActivityIndicatorView{
    
	[activityIndicatorView removeActivityIndicator];
	
}


- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{   
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)mapButton_Action:(id)sender{
    
    mapviewcontroller=[[MyOffersMapViewController alloc]initWithNibName:@"MyOffersMapViewController" bundle:[NSBundle mainBundle]];
    
    if ([myOffersArray count]>0 && !searching) {
        mapviewcontroller.myoffersMapArray = myOffersArray;
        [self.navigationController pushViewController:mapviewcontroller animated:YES];
    }
    else if([searchingArray count]>0 && searching){
        mapviewcontroller.myoffersMapArray = searchingArray;
        [self.navigationController pushViewController:mapviewcontroller animated:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if (searching)
    {
        if ([searchingArray count]==0) {
            myOfferTableView.tableFooterView.hidden=YES;
        }
		return [searchingArray count];
    }
	else
		return [myOffersArray count];

}

#define ASYNC_IMAGE_TAG 999

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    MyOffersTableviewCell *cell = (MyOffersTableviewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"MyOffersTableviewCell" owner:self options:nil];
		cell = customtableviewcell;
        
	}
  if (searching && [searchingArray count] > [indexPath row]){
        NSMutableDictionary *dic = [searchingArray objectAtIndex:indexPath.row];
        [myOfferTableView.tableFooterView setHidden:YES];
        
        NSArray *dateArr = [[dic valueForKey:@"reserved_time_stamp"] componentsSeparatedByString:@" "];
        
        NSDateFormatter *dff = [[NSDateFormatter alloc] init];
        
        [dff setDateFormat:@"YYYY-MM-dd"];
        NSString *dateStrig = [NSString stringWithFormat:@"%@",[dateArr objectAtIndex:0]];
        NSDate *date = [dff dateFromString:dateStrig];
        
        NSDateFormatter *dateformstring = [[NSDateFormatter alloc] init];
        [dateformstring setDateFormat:@"MM-dd-YYYY"];
        NSString *resultDate4 = [dateformstring stringFromDate:date];
    
        customtableviewcell.dateandtime .text =[NSString stringWithFormat:@"%@, %@ to %@", resultDate4,[dic valueForKey:@"start_time"],[dic valueForKey:@"end_time"]] ;
        
        customtableviewcell .deal_name.text = [dic valueForKey:@"deal_name"];
        customtableviewcell.business_name.text=[dic valueForKey:@"business_name"];
        NSString *conformationId=[NSString stringWithFormat:@"Confirmation Code: %@",[dic valueForKey:@"con_res_id"]];
        customtableviewcell.conformationId.text=conformationId;
        NSString *urlString = [NSString stringWithFormat:@"%@",[dic valueForKey:@"image_url"]];
        NSURL *url = [NSURL URLWithString:urlString];
        [cell.asyncImageView loadImageFromURL:url];
      
    }
    else{
        
    
    noOfOffers=[[[myOffersArray objectAtIndex:0]objectForKey:@"noOfdeals"]integerValue];
    if (noOfOffers>10) {
        showMore=[UIButton buttonWithType:UIButtonTypeCustom];
        [showMore setFrame:CGRectMake(0, 210, 320, 40)];
        [showMore setImage:[UIImage imageNamed:@"dark_showmore_btn.png"] forState:UIControlStateNormal];
        [showMore addTarget:self action:@selector(showMoreAction:) forControlEvents:UIControlEventTouchUpInside];
        myOfferTableView.tableFooterView=showMore;
    }
    if([myOffersArray count]==noOfOffers){
        myOfferTableView.tableFooterView.hidden=YES;
    }
    NSArray *dateArr = [[[myOffersArray objectAtIndex:indexPath.row]objectForKey:@"reserved_time_stamp"] componentsSeparatedByString:@" "];
    
    NSDateFormatter *dff = [[NSDateFormatter alloc] init];
    
    [dff setDateFormat:@"YYYY-MM-dd"];
    NSString *dateStrig = [NSString stringWithFormat:@"%@",[dateArr objectAtIndex:0]];
    NSDate *date = [dff dateFromString:dateStrig];
    
    NSDateFormatter *dateformstring = [[NSDateFormatter alloc] init];
    [dateformstring setDateFormat:@"MM-dd-YYYY"];
    NSString *resultDate4 = [dateformstring stringFromDate:date];
    customtableviewcell.dateandtime.text =[NSString stringWithFormat:@"%@, %@ to %@",resultDate4 ,[[myOffersArray objectAtIndex:indexPath.row]objectForKey:@"start_time"],[[myOffersArray objectAtIndex:indexPath.row]objectForKey:@"end_time"]] ;
    customtableviewcell.business_name.text=[[myOffersArray objectAtIndex:indexPath.row]objectForKey:@"business_name"];
    customtableviewcell.deal_name.text=[[myOffersArray objectAtIndex:indexPath.row]objectForKey:@"deal_name"];
        NSString *conformationId=[NSString stringWithFormat:@"Confirmation Code: %@",[[myOffersArray objectAtIndex:indexPath.row] objectForKey:@"con_res_id"]];
        customtableviewcell.conformationId.text=conformationId;
   NSString *urlString = [NSString stringWithFormat:@"%@",[[myOffersArray objectAtIndex:indexPath.row]objectForKey:@"image_url"]];
    urlString = [[urlString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@""];
    NSURL *url = [NSURL URLWithString:urlString];
    [cell.asyncImageView loadImageFromURL:url];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;

}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 88;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    checkView=[[CheckinViewController alloc]initWithNibName:@"CheckinViewController" bundle:[NSBundle mainBundle]];
    
    if ([searchingArray count] !=0 && searching) {
        checkView.checkinDetails=[searchingArray objectAtIndex:indexPath.row];
    }
    else if ([myOffersArray count] !=0) {
        
            checkView.checkinDetails=[myOffersArray objectAtIndex:indexPath.row];
       
    }
    [self.navigationController pushViewController:checkView animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
-(void)showMoreAction:(id)sender{
    map_button.enabled = NO;
    appdelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    if ([myOffersArray count]!=noOfOffers) {
        
        serverURL = [[NSString alloc]initWithFormat:@"%@/mydeals/alldeals?emailId=%@&password=%@&noOfdeals=0&pageIndex=%i",SERVER_URL,[appdelegate.userdetails objectForKey:@"login"],[appdelegate.userdetails objectForKey:@"psw"],  pageIndex];
        
        NSString *terString = [serverURL stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
        NSURL *url = [NSURL URLWithString:[terString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        [self sendASIHTTPRequest:url];
        pageIndex++;
    }
    else{
        myOfferTableView.tableFooterView.hidden=YES;
    }
}

//Search Action
- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    if ([theSearchBar.text length] !=0) {
        
    searching = YES;
    letUserSelectRow = NO;
    map_button.enabled=NO;
    self.myOfferTableView.scrollEnabled = NO;
    }
    myDealsSearchBar.showsCancelButton = YES;
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
        
        [cMyDealsArray removeAllObjects];
        
        if([searchText length] > 0) { 
            searching = YES;
            letUserSelectRow = YES;
            self.myOfferTableView.scrollEnabled = YES;
            [self searchTableView];
        }
        else {
            searching = NO;
            letUserSelectRow = NO;
            self.myOfferTableView.scrollEnabled = NO;
        }
        [self.myOfferTableView reloadData];
}


- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar 
{
    myDealsSearchBar.showsCancelButton = NO;
}


- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    map_button.enabled=YES;
	[myDealsSearchBar resignFirstResponder];
	[myDealsSearchBar setShowsSearchResultsButton:YES];
    [myOfferTableView setScrollEnabled:YES];
}
- (void) searchTableView {
        NSString *searchText = myDealsSearchBar.text;
        NSMutableArray *searchArray = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dictionary in myOffersArray)
        {
            NSString *string = [dictionary objectForKey:@"business_name"];
            [searchArray addObject:string];
        }
        for (NSString *sTemp in searchArray)
        {
            NSRange titleResultsRange = [sTemp rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (titleResultsRange.length > 0)
                [cMyDealsArray addObject:sTemp];
        }
        [searchArray release];
        searchArray = nil;
        [self displayTableView];
}
#pragma mark -
#pragma mark Search Methods
-(void)displayTableView {
        [searchingArray removeAllObjects];
        NSMutableArray *tempArray=[[NSMutableArray alloc] initWithArray:myOffersArray];
        for (int i=0; i<[cMyDealsArray count]; i++) {
            for (int j=0; j<[tempArray count]; j++) {
                NSMutableDictionary	*dic = [tempArray objectAtIndex:j];
                
                if ([[cMyDealsArray objectAtIndex:i] isEqualToString:[dic valueForKey:@"business_name"] ]) {
                    
                    [searchingArray addObject:[tempArray objectAtIndex:j]];
                    [tempArray removeObjectAtIndex:j];
                }
            }
        }
        [tempArray release];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
	myDealsSearchBar.text = @"";
    map_button.enabled=YES;
	[myDealsSearchBar resignFirstResponder];
	[myDealsSearchBar setShowsSearchResultsButton:NO];
	letUserSelectRow = YES;
	searching = NO;
	self.myOfferTableView.scrollEnabled = YES;
	[self.myOfferTableView reloadData];
}

-(void)dealloc{
    [checkView release];
    [deal_name release];
    [isconsumershownup release];
    [host_manager_emailid release];[deal_description release];
    [deal_restrictions release];
    [start_time release];
    [end_time release];
    [business_name release];
    [reserved_time_stamp release];
    [address release];
    [image_url release];
    [noOfdeals release];
    [currentElement release];
    [deal_id release];
    [overlayview release];
    [con_res_id release];
    [deal_manager_emailid release];
    [deal_id release];
    [myOffersArray release];
    [cMyDealsArray release];
    [searchingArray release];
    [networkQueue cancelAllOperations];
    [networkQueue release];
}


@end
