//
//  ManagerTableViewController.m
//  WFChatUIKit
//
//  Created by heavyrain lee on 2019/6/26.
//  Copyright © 2019 WildFireChat. All rights reserved.
//

#import "GroupMemberControlTableViewController.h"
#import "SDWebImage.h"
#import "WFCUContactListViewController.h"
#import "WFCUGeneralSwitchTableViewCell.h"
#import "WFCUConfigManager.h"

@interface GroupMemberControlTableViewController () <UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)NSMutableArray<WFCCGroupMember *> *managerList;
@end

@implementation GroupMemberControlTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = WFCString(@"MemberPrivilege");
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView reloadData];
    
    [self.view addSubview:self.tableView];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    WFCUGeneralSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[WFCUGeneralSwitchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    

        cell.on = !self.groupInfo.privateChat;
        cell.textLabel.text = WFCString(@"AllowTemporarySession");
        cell.onSwitch = ^(BOOL value, void (^onDone)(BOOL success)) {
            NSDictionary *dict = [WFCUConfigManager getApiClient];
            NSString *_onfls = dict[@"onfgrouplinshi"];
            int _onf = [_onfls intValue];
            if(_onf==1){
                [[WFCCIMService sharedWFCIMService] modifyGroupInfo:self.groupInfo.target type:Modify_Group_PrivateChat newValue:value?@"0":@"1" notifyLines:@[@(0)] notifyContent:nil success:^{
                    onDone(YES);
                } error:^(int error_code) {
                    onDone(NO);
                }];
            }else{
                [self alert:@"管理员禁止该功能"];
            }
        };
    
   
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(void)alert:(NSString*) text{
    UIAlertView *_alert = [[UIAlertView alloc]initWithTitle:@"提示" message:text delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [_alert show];
}
@end
