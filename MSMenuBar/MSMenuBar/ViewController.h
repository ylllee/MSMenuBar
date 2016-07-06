//
//  ViewController.h
//  MSMenuBar
//
//  Created by limingshan on 16/7/6.
//  Copyright © 2016年 limingshan. All rights reserved.
//

// 表视图的tag
#define kContentView 1200

#import <UIKit/UIKit.h>

#import "MSMenuBar.h"

#import "UIViewExt.h"

@interface ViewController : UIViewController <MSMenuBarDelegate,UITableViewDataSource,UITableViewDelegate> {
    MSMenuBar *_menuBar;
    NSArray *_menuTitles;
    NSArray *_contentViews;
}


@end

