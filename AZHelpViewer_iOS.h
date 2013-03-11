//
//  AZHelpViewe_iOS.h
//  write.out
//
//  Created by Andreas Zöllner on 10.03.13.
//  Copyright (c) 2013 Studio Istanbul. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AZHelpViewer : UIViewController <NSXMLParserDelegate, UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate> {
    IBOutlet UIView* contentView;
    IBOutlet UIWebView* htmlContent;
    IBOutlet UITableView* anchorTable;
}
@property (nonatomic, retain) NSString* path;
@property (nonatomic, retain) NSString* anchor;
@property (nonatomic, retain) NSArray* topics;
@property (nonatomic, retain) NSArray* anchors;
@property (assign) BOOL tableController;

@end
