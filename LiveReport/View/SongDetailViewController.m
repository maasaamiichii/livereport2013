//
//  SongDetailViewController.m
//  LiveReport2013
//
//  Created by Ueta Masamichi on 2013/03/28.
//  Copyright (c) 2013年 Ueta Masamichi. All rights reserved.
//

#import "SongDetailViewController.h"

#import "UIImage+Resize.h"
#import "UIDevice+VersionCheck_h.h"

#import "PrettyKit.h"

@interface SongDetailViewController ()

@end

@implementation SongDetailViewController
@synthesize songDetailTable=_songDetailTable;
@synthesize songName=_songName;
@synthesize albumName=_albumName;
@synthesize albumPic=_albumPic;
@synthesize itunesLink=_itunesLink;

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
        _songDetailTable.frame = CGRectMake(_songDetailTable.frame.origin.x, _songDetailTable.frame.origin.y + adBannerView.frame.size.height, _songDetailTable.frame.size.width, _songDetailTable.frame.size.height - adBannerView.frame.size.height);
    }
    else{
        _songDetailTable.frame = CGRectMake(_songDetailTable.frame.origin.x, 0, _songDetailTable.frame.size.width, self.view.frame.size.height);
    }
    
}


#pragma mark -
#pragma mark Initialization
- (void) initTableView{
    _songDetailTable.delegate = self;
    _songDetailTable.dataSource = self;
    _songDetailTable.scrollsToTop = YES;
    //[_songDetailTable dropShadows];
    //_songDetailTable.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
}

-(void) initIAd{
    adBannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    adBannerView.delegate = self;
    adBannerView.frame = CGRectOffset(adBannerView.frame, 0.0, -adBannerView.frame.size.height);
    bannerIsVisible=NO;
    [self.view addSubview:adBannerView];
}


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
    self.navigationItem.title = _songName;
    [self initTableView];
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
    if([_itunesLink length] != 0) return 2;
    else return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    switch (section) {
        case 0:{
            NSString* tableHeader = NSLocalizedString(@"Song Info", @"Song Link");
            return tableHeader;
        }
            break;
        case 1:{
            NSString* tableHeader = NSLocalizedString(@"iTunes Link", @"iTunes Link");
            return tableHeader;
        }
            break;
        default:
            break;
    }
    return 0;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
            return 130;
            break;
        case 1:
            return 60;
            break;
        default:
            break;
    }
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    
    
    PrettyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[PrettyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.tableViewBackgroundColor = tableView.backgroundColor;
    
    //PrettyKitSetting
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.minimumScaleFactor = 10;
    cell.textLabel.font = [UIFont systemFontOfSize:10];
    
    if([[UIDevice currentDevice] systemMajorVersion] < 7)
    {
        cell.cornerRadius = 5;
        cell.customSeparatorColor = [UIColor colorWithHex:0xCC3599];
        cell.borderColor = [UIColor colorWithHex:0xCC3599];
        [cell prepareForTableView:tableView indexPath:indexPath];
    }
    else{
        cell.customSeparatorStyle = UITableViewCellSeparatorStyleNone;
    }
    //Cell Content
    switch (indexPath.section) {
        case 0:{
            cell.textLabel.text = _albumName;
            NSString *picName = [NSString stringWithFormat:@"%@.jpg", _albumPic];
            cell.imageView.image = [UIImage getResizedImage:[UIImage imageNamed:picName] width:100.0f height:100.0f];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            
            break;
        case 1:{
            cell.textLabel.text = NSLocalizedString(@"Buy this song in iTunes", @"Buy this song in iTunes");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
            break;
        case 1:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: _itunesLink]];
            break;
            
        default:
            break;
    }
    [_songDetailTable deselectRowAtIndexPath:[_songDetailTable indexPathForSelectedRow] animated:NO];
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
        _songDetailTable.frame = CGRectMake(_songDetailTable.frame.origin.x, _songDetailTable.frame.origin.y + adBannerView.frame.size.height, _songDetailTable.frame.size.width, _songDetailTable.frame.size.height - adBannerView.frame.size.height);
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
        _songDetailTable.frame = CGRectMake(_songDetailTable.frame.origin.x, 0, _songDetailTable.frame.size.width, self.view.frame.size.height);
    }
}

@end