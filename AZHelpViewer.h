//
//  AZHelpViewer.h
//  exchangeExport
//
//  Created by AVID Editor on 10/9/12.
//  Copyright (c) 2012 Studio Istanbul. All rights reserved.
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <WebKit/WebKit.h>
#import "UKNibOwner.h"
#endif

#if TARGET_OS_IPHONE
@interface AZHelpViewer : NSObject {
#else
@interface AZHelpViewer : UKNibOwner {
    IBOutlet WebView* pageview;
    IBOutlet NSTreeController* indexController;
    IBOutlet NSWindow* helpWindow;
    IBOutlet NSOutlineView* indexView;
#endif
    NSMutableArray* index;
    NSString *_cdirectory;
    NSString* displayFile;
    BOOL visible;
}

@property (readwrite,assign) NSString* cdirectory;
@property (readonly) BOOL visible;
#if TARGET_OS_IPHONE
#else
@property (readonly) NSWindow* helpWindow;
#endif
    
-(AZHelpViewer*) initWithDirectory:(NSString*)xdirectory;
-(void)show;
-(void)setDisplayPage:(NSString*) path;
@end
