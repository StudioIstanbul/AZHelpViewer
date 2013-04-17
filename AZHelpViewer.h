//
//  AZHelpViewer.h
//  exchangeExport
//
//  Created by AVID Editor on 10/9/12.
//  Copyright (c) 2012 Studio Istanbul. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "UKNibOwner.h"

@interface AZHelpViewer : UKNibOwner {
    IBOutlet WebView* pageview;
    IBOutlet NSTreeController* indexController;
    IBOutlet NSWindow* helpWindow;
    IBOutlet NSOutlineView* indexView;
    NSMutableArray* index;
    NSString *_cdirectory;
    NSString* displayFile;
    BOOL visible;
}

@property (readwrite,retain) NSString* cdirectory;
@property (readonly) BOOL visible;
@property (readonly) NSWindow* helpWindow;
@property (retain) NSString* displayFile;

-(AZHelpViewer*) initWithDirectory:(NSString*)xdirectory;
-(void)show;
-(void)setDisplayPage:(NSString*) path;
@end
