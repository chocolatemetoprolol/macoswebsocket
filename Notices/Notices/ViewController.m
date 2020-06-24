//
//  ViewController.m
//  Notices
//
//  Created by 11 on 2020/6/8.
//  Copyright © 2020 arron. All rights reserved.
//

#import "ViewController.h"
#import <SocketRocket/SRWebSocket.h>
#import <UserNotifications/UserNotifications.h>
#import "NSDate+Extension.h"

@interface ViewController ()<SRWebSocketDelegate,NSTextFieldDelegate,NSTableViewDelegate,NSTableViewDataSource,NSUserNotificationCenterDelegate>
{
    SRWebSocket *_webSocket;
}
@property (strong)  NSMutableArray      *conversionArray;
@property (strong) IBOutlet NSTextField *inputTextField;
@property (strong) IBOutlet NSButton *connectBtn;
@property (strong) IBOutlet NSScrollView *contentView;
@property (strong) IBOutlet NSTableView *contentTable;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.conversionArray = [[NSMutableArray alloc]init];
    self.inputTextField.delegate = self;
    self.contentTable.dataSource = self;
    self.contentTable.delegate = self;
    self.inputTextField.stringValue = @"ws://192.168.0.21:8092/websocket";
    // Do any additional setup after loading the view.
}

- (IBAction)sendMessage:(NSButton *)sender {
    if ([sender.title isEqualToString:@"连接"]) {
        [self connectWebSocket];
        return;
    }
    if (self.inputTextField.stringValue.length > 0) {
        [_webSocket send:self.inputTextField.stringValue];
        self.inputTextField.stringValue = @"";
    }
}

- (void)connectWebSocket {
    _webSocket.delegate = nil;
    _webSocket = nil;
    NSString *urlString = self.inputTextField.stringValue;
    if (urlString.length > 0) {
        SRWebSocket *newWebSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:urlString]];
        newWebSocket.delegate = self;
        [newWebSocket open];
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.conversionArray.count;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    NSDictionary *textDic = [self.conversionArray objectAtIndex:row];
    if (tableColumn == tableView.tableColumns[0]) {
        NSString *date = [textDic objectForKey:@"date"];
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"NameCellID" owner:self];
        cell.textField.stringValue = date;
        return cell;
    }
    NSString *message = [textDic objectForKey:@"message"];
    NSTableCellView *cell = [tableView makeViewWithIdentifier:@"DateCellID" owner:self];
    cell.textField.stringValue = message;
    return cell;
}

#pragma mark - SRWebSocket delegate

- (void)webSocketDidOpen:(SRWebSocket *)newWebSocket {
  _webSocket = newWebSocket;
    [self.connectBtn setTitle:@"发送"];
    self.inputTextField.stringValue = @"";
    self.inputTextField.placeholderString = @"请输入发送内容";
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
  NSLog(@"%s error %@",__FUNCTION__,error);
  [self connectWebSocket];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
  NSLog(@"%s reason %@",__FUNCTION__,reason);
  [self connectWebSocket];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSLog(@"%s message %@",__FUNCTION__,message);
    NSString *date = [NSDate getDateStringWithDate];
    NSDictionary *dataDic = @{@"date":date,@"message":message};
    [self.conversionArray addObject:dataDic];
    [self.contentTable reloadData];
    NSUserNotification *user = [[NSUserNotification alloc]init];
    user.title = @"新消息";
    user.informativeText = message;
//    NSImage *image = [NSImage imageNamed:@"AppIcon"];
//    user.contentImage = image;
    user.soundName = NSUserNotificationDefaultSoundName;
    user.deliveryDate = [[NSDate alloc]initWithTimeIntervalSinceNow:2];
    NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
    [center deliverNotification:user];
    center.delegate = self;
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification {
    NSLog(@"%s notification %@",__FUNCTION__,notification);
    [[[NSApplication sharedApplication] dockTile] setBadgeLabel:notification.title];
}

// Sent to the delegate when a user clicks on a notification in the notification center. This would be a good time to take action in response to user interacting with a specific notification.
// Important: If want to take an action when your application is launched as a result of a user clicking on a notification, be sure to implement the applicationDidFinishLaunching: method on your NSApplicationDelegate. The notification parameter to that method has a userInfo dictionary, and that dictionary has the NSApplicationLaunchUserNotificationKey key. The value of that key is the NSUserNotification that caused the application to launch. The NSUserNotification is delivered to the NSApplication delegate because that message will be sent before your application has a chance to set a delegate for the NSUserNotificationCenter.
- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    NSLog(@"%s notification %@",__FUNCTION__,notification);
    [[[NSApplication sharedApplication] dockTile] setBadgeLabel:nil];
//    [center removeDeliveredNotification:notification];
    [center removeAllDeliveredNotifications];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    // Update the view, if already loaded.
}

@end
