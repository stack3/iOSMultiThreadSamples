//
//  STViewController.m
//  MultiThreadSamples
//
//  Created by EIMEI on 2013/09/01.
//  Copyright (c) 2013年 stack3. All rights reserved.
//

#import "STViewController.h"

typedef enum {
    _MenuItemNSThread,
    _MenuItemDispatchAsync,
    _MenuItemBackgroundTask
} _MenuItems;

@implementation STViewController {
    IBOutlet __weak UITableView *_tableView;
    __strong NSMutableArray *_rows;
    NSUInteger _threadCount;
}

- (id)init
{
    self = [super initWithNibName:@"STViewController" bundle:nil];
    if (self) {
        _rows = [NSMutableArray arrayWithCapacity:10];
        [_rows addObject:@"NSThread"];
        [_rows addObject:@"DispatchAsync"];
        [_rows addObject:@"BackgroundTask"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = @"CellId";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    NSString *row = [_rows objectAtIndex:indexPath.row];
    cell.textLabel.text = row;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _MenuItemNSThread) {
        [self startNSThread];
    } else if (indexPath.row == _MenuItemDispatchAsync) {
        [self startDispatchAsync];
    } else if (indexPath.row == _MenuItemBackgroundTask) {
        [self startBackgroundTask];
    }
    
    
    [_tableView deselectRowAtIndexPath:_tableView.indexPathForSelectedRow animated:YES];
}

- (void)startNSThread
{
    _threadCount++;
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(nsThreadAction) object:nil];
    thread.name = [NSString stringWithFormat:@"NSThread %u", _threadCount];
    [thread start];
}

- (void)nsThreadAction
{
    NSUInteger count = 0;
    while (YES) {
        count++;
        NSLog(@"NSThread name:%@ count:%u", [[NSThread currentThread] description], count);
        [NSThread sleepForTimeInterval:1];
    }
}

- (void)startDispatchAsync
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUInteger count = 0;
        while (YES) {
            count++;
            NSLog(@"dispatch_async name:%@ count:%u", [[NSThread currentThread] description], count);
            [NSThread sleepForTimeInterval:1];
        }
    });
}

- (void)startBackgroundTask
{
    if (![[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]) {
        NSLog(@"Multitasking is not supported.");
    }
    
    __weak UIViewController *weakSelf = self;
    __block UIBackgroundTaskIdentifier backgroundTask;
    backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^ {
        [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
        backgroundTask = UIBackgroundTaskInvalid;
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUInteger count = 0;
        for (int i = 0; i < 10; i++) {
            count++;
            // NSLog(@"Background time Remaining: %f",[[UIApplication sharedApplication] backgroundTimeRemaining]);
            NSLog(@"backgroundTask name:%@ count:%u", [[NSThread currentThread] description], count);
            [NSThread sleepForTimeInterval:1];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf) {
                    weakSelf.title = [NSString stringWithFormat:@"Count:%u", count];
                }
            });
        }
        
        [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
        backgroundTask = UIBackgroundTaskInvalid;
    });
}

@end
