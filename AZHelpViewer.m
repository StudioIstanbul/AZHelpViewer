//
//  AZHelpViewer.m
//  exchangeExport
//
//  Created by AVID Editor on 10/9/12.
//  Copyright (c) 2012 Studio Istanbul. All rights reserved.
//

#import "AZHelpViewer.h"

@implementation AZHelpViewer

@synthesize directory;

-(AZHelpViewer*) initWithDirectory:(NSString*)xdirectory {
    NSLog(@"init");
    if (self = [super init]) {
        NSLog(@"setting variables");
        [self setDirectory:xdirectory];
        [self setDisplayPage:[NSString pathWithComponents:[NSArray arrayWithObjects:directory, @"index.html", nil]]];
        //[obj showWindow:self];
        
    }
    return self;
}

-(void)show {
    NSLog(@"show %@", [helpWindow title]);
    [helpWindow makeKeyAndOrderFront:self];
    
}

-(void)outlineViewSelectionDidChange:(id)notification {
    if ([[indexController selectedObjects] count] > 0) {
        NSDictionary* sel = [[indexController selectedObjects] objectAtIndex:0];
        if ([sel valueForKey:@"title"]) {
            NSLog(@"selection changed to %@", [sel valueForKey:@"title"]);
            [[pageview mainFrame] loadHTMLString:[NSString stringWithContentsOfURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",directory,[sel valueForKey:@"url"]]] encoding:NSUTF8StringEncoding error:nil] baseURL:[NSURL fileURLWithPath:[self directory] isDirectory:YES]];
        }
    }
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    if ([[indexController selectedObjects] count] > 0) {
        DOMDocument *doc = [[pageview mainFrame] DOMDocument];
        DOMElement *titleTag = [[doc getElementsByTagName:@"title"] item:0];
        NSString *title = [titleTag innerText];
        int pagNum = 0;
        NSDictionary* sel = [[indexController selectedObjects] objectAtIndex:0];
        NSIndexPath* selItem = [indexController selectionIndexPath];
        [indexView collapseItem:nil collapseChildren:YES];
        for (NSDictionary* pages in [indexController content]) {
            if ([[pages valueForKey:@"title"] compare:title] == NSOrderedSame) {
                NSLog(@"mainpage: %i / selected %i", [selItem indexAtPosition:0], pagNum);
                if ([selItem indexAtPosition:0] != pagNum) {
                    [indexController setSelectionIndexPath:[NSIndexPath indexPathWithIndex:pagNum]];
                    selItem = [indexController selectionIndexPath];
                }
            }
            pagNum++;
        }
    
        if ([sel valueForKey:@"anchorId"]) {
            DOMElement *element = [doc getElementById:[sel valueForKey:@"anchorId"]];
            NSLog(@"scrolling to %@ on page %@", [sel valueForKey:@"anchorId"], title);
            [element scrollIntoView:YES];
        }
        
        [indexView expandItem:[indexView itemAtRow:[selItem indexAtPosition:0]]];
        //[indexController setSelectionIndexPath:selItem];
    }
}

-(void)setDisplayPage:(NSString*) path {
    NSLog(@"set page %@", path);
    [[pageview mainFrame] loadHTMLString:[NSString stringWithContentsOfURL:[NSURL fileURLWithPath:path] encoding:NSUTF8StringEncoding error:nil] baseURL:[NSURL fileURLWithPath:[self directory] isDirectory:YES]];
    NSLog(@"populate tree");
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:nil];
    index = [[NSMutableArray alloc]init];
    [indexController setContent:index];
    int indInt = 0;
    NSIndexPath* indexPageNum = [NSIndexPath indexPathWithIndex:0];
    for (NSString* file in files) {
        if ([file rangeOfString:@".html"].location != NSNotFound) {
            NSLog(@"scanning %@", file);
            NSString* fcont = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", directory, file] encoding:NSUTF8StringEncoding error:nil];
            NSRange titleRange = [fcont rangeOfString:@"<title>"];
            if (titleRange.location != NSNotFound) {
                titleRange.location += 7;
                titleRange.length = [fcont rangeOfString:@"</title>"].location - titleRange.location;
                NSString *title = [fcont substringWithRange:titleRange];
                // Scan for anchors
                
                NSArray *anchorcont = [fcont componentsSeparatedByString:@"<h3"];
                
                NSMutableArray *anchors = [[NSMutableArray alloc] init];
                
                int anchNum = 0;
                
                for (NSString* acitem in anchorcont) {
                    if ([acitem rangeOfString:@"id=\""].location != NSNotFound && anchNum != 0) {
                        NSString* idString = [acitem substringFromIndex:[acitem rangeOfString:@"id=\""].location + 4];
                        idString = [idString substringWithRange:NSMakeRange(0, [idString rangeOfString:@"\""].location)];
                        NSRange atit = NSMakeRange([acitem rangeOfString:@">"].location+1 , [acitem rangeOfString:@"</h3>"].location - [acitem rangeOfString:@">"].location -1);
                        [anchors addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[acitem substringWithRange:atit], file, idString, nil] forKeys:[NSArray arrayWithObjects:@"title", @"url", @"anchorId", nil]]];
                    }
                    anchNum++;
                }
                
                //[anchors removeObjectAtIndex:0];
                
                NSDictionary* page = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:title, file, anchors, nil] forKeys:[NSArray arrayWithObjects:@"title", @"url", @"anchors", nil]];
                [index addObject:page];
                if ([file compare:[path lastPathComponent]] == NSOrderedSame) {
                    NSLog(@"index page %i", indInt);
                    indexPageNum = [NSIndexPath indexPathWithIndex:indInt];
                    if ([anchors count] > 0) {
                        //indexPageNum = [indexPageNum indexPathByAddingIndex:0];
                    }
                }
                indInt++;
            }
        }
    }
    //[indexController setContent:index];
    [indexController rearrangeObjects];
    [indexController setSelectionIndexPath:indexPageNum];
}

@end
