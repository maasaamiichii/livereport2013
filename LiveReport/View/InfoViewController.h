//
//  InfoViewController.h
//  LiveReport2013
//
//  Created by Ueta Masamichi on 2013/03/28.
//  Copyright (c) 2013年 Ueta Masamichi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iAd/iAd.h"

@interface InfoViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, ADBannerViewDelegate>{
    
    ADBannerView *adBannerView;
    BOOL bannerIsVisible;
}

@property (strong, nonatomic) IBOutlet UITableView *infoTable;

@end
