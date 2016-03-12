//
//  PlaceViewController.m
//  LiveReport2013
//
//  Created by Ueta Masamichi on 2013/03/20.
//  Copyright (c) 2013年 Ueta Masamichi. All rights reserved.
//

#import "PlaceViewController.h"

#import "PlaceToggleControl.h"
#import "ImageUtil.h"
#import "PostInfoUtil.h"
#import "UIDevice+VersionCheck_h.h"

#import "PrettyKit.h"

@interface PlaceViewController ()

@end

@implementation PlaceViewController
@synthesize placeListTable = _placeListTable;
@synthesize liveReportObj = _liveReportObj;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)FromInterfaceOrientation {
    if(bannerIsVisible){
        adBannerView.frame = CGRectMake(adBannerView.frame.origin.x, adBannerView.frame.origin.y, self.view.frame.size.width, adBannerView.frame.size.height);
        _placeListTable.frame = CGRectMake(_placeListTable.frame.origin.x, _placeListTable.frame.origin.y + adBannerView.frame.size.height, _placeListTable.frame.size.width, _placeListTable.frame.size.height - adBannerView.frame.size.height);
    }
    else{
        _placeListTable.frame = CGRectMake(_placeListTable.frame.origin.x, 0, _placeListTable.frame.size.width, self.view.frame.size.height);
    }
    
}


#pragma mark -
#pragma mark Initialization
-(void) initNavBar{
    if([[UIDevice currentDevice] systemMajorVersion] < 7)
    {
        self.navigationController.navigationBar.tintColor = [UIColor colorWithHex:0xCC3599];
    }
    self.navigationItem.title = NSLocalizedString(@"Place List", @"Place List");
}
- (void) initTableView{
    _placeListTable.delegate = self;
    _placeListTable.dataSource = self;
    _placeListTable.scrollsToTop = YES;
    
    //[_placeListTable dropShadows];
    //_placeListTable.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
}

-(void) initToggleControl{
    toggleControlList = [NSMutableArray array];
    for(int i=0;i<[placeList count];i++){
        PlaceToggleControl *toggleControl = [[PlaceToggleControl alloc] initWithFrame: CGRectMake(0,0,60,60)];
        toggleControl.tag = i;
        toggleControl.placeName = [[placeList objectAtIndex:i] objectForKey:@"name"];
        [toggleControlList addObject:toggleControl];
    }

    //Register NC in PlaceToggleControl
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(placeTogglePushed:) name:@"PlaceTogglePushed" object:nil];
}

-(void) initIAd{
    adBannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    adBannerView.delegate = self;
    adBannerView.frame = CGRectOffset(adBannerView.frame, 0.0, -adBannerView.frame.size.height);
    bannerIsVisible=NO;
    [self.view addSubview:adBannerView];
}



#pragma mark -
#pragma mark View Life Cycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [self initNavBar];
    [self initTableView];
    
    _liveReportObj = [[LiveReportDAO alloc] init];
    placeList = [NSMutableArray array];
    placeList = _liveReportObj.getPlaceList;
    
        
    [self initToggleControl];
    [self initIAd];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark UITableView Delegate Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    //Localize
    NSString* tableHeader = NSLocalizedString(@"Select Place", @"Select Place");
    return tableHeader;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 60;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [placeList count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    
    PrettyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[PrettyTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    cell.tableViewBackgroundColor = tableView.backgroundColor;
    
    //PrettyKitSetting
    if([[UIDevice currentDevice] systemMajorVersion] < 7)
    {
        cell.cornerRadius = 5;
        cell.customSeparatorColor = [UIColor colorWithHex:0xCC3599];
        cell.borderColor = [UIColor colorWithHex:0xCC3599];
        [cell prepareForTableView:tableView indexPath:indexPath];
    }
    else {
        cell.customSeparatorStyle = UITableViewCellSeparatorStyleNone;
    }
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.minimumScaleFactor = 10;
    cell.textLabel.font = [UIFont systemFontOfSize:10];
    
    
    //Cell Content
    cell.textLabel.text = [[placeList objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.detailTextLabel.text = [[placeList objectAtIndex:indexPath.row] objectForKey:@"date"];
    
    
    
    //Check Mark
    cell.imageView.image = [ImageUtil imageWithColor:[UIColor clearColor]];
    [cell.contentView addSubview: [toggleControlList objectAtIndex:indexPath.row]];
    
    
    return cell;
    
}


//Called when place toggle is pushed
-(void)placeTogglePushed:(NSNotification*) notification{

    NSDictionary *placeDic = [[notification userInfo] objectForKey:@"Place"];
    for(int i=0; i<[toggleControlList count]; i++){
        PlaceToggleControl *toggleControl = [toggleControlList objectAtIndex:i];
        if([[placeDic objectForKey:@"tag"] intValue] != i && toggleControl.selected == 1){
            toggleControl.selected = 0;
            toggleControl.imageView.image = toggleControl.normalImage;
        }
    }
    PostInfoUtil *postInfo = [PostInfoUtil sharedCenter];
    if([[placeDic objectForKey:@"selected"] intValue] == 1){
        postInfo.place = [placeDic objectForKey:@"placeName"];
    } else{
        postInfo.place = @"";
    }

    
}


#pragma mark -
#pragma mark AdBannerView Delegate Methods
-(void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        banner.frame = CGRectOffset(banner.frame, 0, adBannerView.frame.size.height);
        [UIView commitAnimations];
        
        bannerIsVisible = YES;
        adBannerView.frame = CGRectMake(adBannerView.frame.origin.x, adBannerView.frame.origin.y, self.view.frame.size.width, adBannerView.frame.size.height);
        _placeListTable.frame = CGRectMake(_placeListTable.frame.origin.x, _placeListTable.frame.origin.y + adBannerView.frame.size.height, _placeListTable.frame.size.width, _placeListTable.frame.size.height - adBannerView.frame.size.height);
    }
}


-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        banner.frame = CGRectOffset(banner.frame, 0, -adBannerView.frame.size.height);
        [UIView commitAnimations];
        bannerIsVisible = NO;
        _placeListTable.frame = CGRectMake(_placeListTable.frame.origin.x, 0, _placeListTable.frame.size.width, self.view.frame.size.height);
    }
}



@end