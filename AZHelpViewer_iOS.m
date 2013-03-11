//
//  AZHelpViewe_iOS.m
//  write.out
//
//  Created by Andreas Zöllner on 10.03.13.
//  Copyright (c) 2013 Studio Istanbul. All rights reserved.
//

#import "AZHelpViewer_iOS.h"
#import "TFHpple.h"

@interface AZHelpViewer ()

@end

@implementation AZHelpViewer
@synthesize path, anchor;
@synthesize topics, anchors, tableController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close)];
    // Do any additional setup after loading the view from its nib.
}

-(void)close {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    NSLog(@"dealloc help viewer");
    if (self.path) self.path = nil;
    if (self.anchor) self.anchor = nil;
    if (self.anchors) self.anchors = nil;
    if (self.topics) self.topics = nil;
    [super dealloc];
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
}

-(void)scanHelpFile:(NSString*) file {
    NSLog(@"scanning help file: %@", file);
    TFHpple* parser = [[TFHpple alloc] initWithHTMLData:[NSData dataWithContentsOfFile:file]];
    NSString* title = [[[parser searchWithXPathQuery:@"//title"] lastObject] text];
    NSArray* anchs = [parser searchWithXPathQuery:@"//h3"];
    NSMutableArray* elemsToAdd = [[[NSMutableArray alloc] initWithCapacity:anchs.count] autorelease];
    for (TFHppleElement* elem in anchs) {
        [elemsToAdd addObject:[NSDictionary dictionaryWithObjectsAndKeys:elem.text, @"title", [elem.attributes valueForKey:@"id"], @"id", nil]];
    }
    NSLog(@"title: %@", title);
    self.topics = [self.topics arrayByAddingObject:title];
    self.anchors = [self.anchors arrayByAddingObject:[NSDictionary dictionaryWithObjectsAndKeys:file, @"file", elemsToAdd, @"anchors", nil]];
    //NSLog(@"anchors: %@", anchs);
}

-(void)viewWillAppear:(BOOL)animated {
    if (!topics || self.tableController) {
        self.topics = [NSArray array];
        self.anchors = [NSArray array];
        NSArray* availableFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self.path stringByDeletingLastPathComponent] error:nil];
        for (NSString* file in availableFiles) {
            if ([file rangeOfString:@".html"].location != NSNotFound) {
                [self scanHelpFile:[[self.path stringByDeletingLastPathComponent] stringByAppendingPathComponent:file]];
            }
        }
        self.title = NSLocalizedString(@"Help", @"help title");
        tableController = YES;
        [anchorTable reloadData];
    } else {
        [self.view addSubview:contentView];
        [self.view bringSubviewToFront:contentView];
        [htmlContent loadHTMLString:[NSString stringWithContentsOfFile:self.path encoding:NSUTF8StringEncoding error:nil] baseURL:[NSURL fileURLWithPath:[self.path stringByDeletingLastPathComponent]]];
        tableController = NO;
    }
    NSLog(@"%i topics", self.topics.count);
    NSLog(@"help appear");
    [super viewWillAppear:animated];
}
             
-(void)webViewDidFinishLoad:(UIWebView *)webView {
    if (self.anchor) {
        NSLog(@"scroll");
        [htmlContent stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.location.hash='%@';", self.anchor]];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"rows in section %i: %i", section, [[[self.anchors objectAtIndex:section] valueForKey:@"anchors"] count]);
    return [[[self.anchors objectAtIndex:section] valueForKey:@"anchors"] count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"number of sections: %i", [self.anchors count]);
    return [self.anchors count];
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.topics objectAtIndex:section];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"row: %i", indexPath.row);
    NSDictionary* elem = [[[self.anchors objectAtIndex:indexPath.section] valueForKey:@"anchors"] objectAtIndex:indexPath.row];
    //NSLog(@"elem: %@", [elem valueForKey:@"title"]);
    cell.textLabel.text = [elem valueForKey:@"title"];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [anchorTable dequeueReusableCellWithIdentifier:@"anchorCell"];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"anchorCell"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selected %@", [[self.anchors objectAtIndex:indexPath.section] valueForKey:@"file"]);
    AZHelpViewer* contentController = [[[AZHelpViewer alloc] initWithNibName:@"AZHelpViewer_iOS" bundle:nil] autorelease];
    contentController.topics = self.topics;
    contentController.anchors = self.anchors;
    contentController.path = [[self.anchors objectAtIndex:indexPath.section] valueForKey:@"file"];
    contentController.anchor = [[[[self.anchors objectAtIndex:indexPath.section] valueForKey:@"anchors"] objectAtIndex:indexPath.row] valueForKey:@"id"];
    contentController.title = [self.topics objectAtIndex:indexPath.section];
    [self.navigationController pushViewController:contentController animated:YES];
}

@end
