//
//  InfoView.m
//  BiliBiliAv
//
//  Created by 邦泰联合 on 16/3/24.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "InfoView.h"
#import "WJSegmentMenu.h"
#import "JianJieHeadView.h"
#import "JianJieLayout.h"
#import "RelateCell.h"
#import "ReplyCell.h"
#import "RreplyCell.h"
#import "ReplyListModel.h"
#import "ReplyLayout.h"
#import "RreplyLayout.h"
#import <UITableView+SDAutoTableViewCellHeight.h>

@interface InfoView ()<WJSegmentMenuDelegate,UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong) WJSegmentMenu * topMenu;
//@property (nonatomic,strong) UILabel * replyNumLabel;
@property(nonatomic,strong) UIScrollView * scrollView;
@property(nonatomic,strong) UITableView * jianJieTableView;
@property(nonatomic,strong) UITableView * conmmentTableView;
@property (nonatomic,copy) NSMutableArray * replyArray;
@end

@implementation InfoView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self topMenu];
        [self scrollView];
        [self jianJieTableView];
        [self conmmentTableView];

    }
    return self;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.jianJieTableView) {
        RelateModel * relate = self.detail.relates[indexPath.row];
        return [tableView cellHeightForIndexPath:indexPath model:relate keyPath:@"relate" cellClass:[RelateCell class] contentViewWidth:self.width];
    }else{
        ReplyListModel * reply = self.replyArray[indexPath.section];
        if (indexPath.row == 0) {
            ReplyLayout * layout = [[ReplyLayout alloc] initWithDetail:reply];
            
            if (self.replyList.hots.count>0&&indexPath.section == self.replyList.hots.count){
                return layout.height+30;
            }else{
                return layout.height;
            }
        }else{
            ReplyListModel * rreply = reply.listReplys[indexPath.row-1];
            RreplyLayout * layout = [[RreplyLayout alloc] initWithDetail:rreply];
            return layout.height;
        }
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.conmmentTableView) {
        return self.replyArray.count;
    }
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.jianJieTableView) {
        return self.detail.relates.count;
    }else{
        ReplyListModel * data = self.replyArray[section];
        return data.listReplys.count+1;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.jianJieTableView) {
        
        RelateCell * cell = [tableView dequeueReusableCellWithIdentifier:@"relate" forIndexPath:indexPath];
        
        cell.relate = self.detail.relates[indexPath.row];
        
        return cell;
    }else{
        ReplyListModel * data = self.replyArray[indexPath.section];
        if (indexPath.row == 0) {
            ReplyCell * cell = [tableView dequeueReusableCellWithIdentifier:@"reply"  forIndexPath:indexPath];
            ReplyLayout * layout = [[ReplyLayout alloc] initWithDetail:data];
            if (self.replyList.hots.count>0){
                if (indexPath.section == self.replyList.hots.count) {
                    [cell hiddeTopLine];
                }else{
                    [cell showTopLine];
                }
                if (indexPath.section == self.replyList.hots.count) {
                    layout.showMoreHot = YES;
                }else{
                    layout.showMoreHot = NO;
                }
            }
            cell.replyLayout = layout;
            return cell;
        }else{
            RreplyCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Rreply" forIndexPath:indexPath];
            ReplyListModel * rdata = data.listReplys[indexPath.row-1];
            RreplyLayout * layout = [[RreplyLayout alloc] initWithDetail:rdata];
            cell.rreplyLayout = layout;
            
            return cell;
        }
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.conmmentTableView) {
        ReplyListModel * data = self.replyArray[indexPath.section];
        if (self.replyBlock) {
            self.replyBlock(data);
        }
    }else{
        RelateModel * relate = self.detail.relates[indexPath.row];
        if (self.reSetBlock) {
            self.reSetBlock(relate);
        }
    }
}

-(void)seleWithBlock:(replyCellClickBlock)block
{
    self.replyBlock = block;
}

-(void)reSetAvPlayerWithBlock:(reSetAvPlayerBlock)block
{
    self.reSetBlock = block;
}

-(void)setReplyList:(ReplyList *)replyList
{
    _replyList = replyList;
    
    if (!replyList) return;
    
    if ([replyList.page.num integerValue]==1) {
        [self.replyArray removeAllObjects];
        for (int i=0; i<3; i++) {
            ReplyListModel * data = replyList.hots[i];
            [self.replyArray addObject:data];
        }
    }
    
    [self.replyArray addObjectsFromArray:replyList.replies];
    [self.conmmentTableView reloadData];
}

-(void)setDetail:(AvDetailModel *)detail
{
    _detail = detail;
    JianJieLayout * layout = [[JianJieLayout alloc] initWithDetail:detail];
    JianJieHeadView * headView = [[JianJieHeadView alloc] init];
    headView.layout = layout;
   // headView.detail = detail;
    self.jianJieTableView.tableHeaderView = headView;
    
    @weakify(self);
    [headView.pageV pageSelectWithBlock:^(NSString *cid) {
        if (weak_self.pageBlock) {
            weak_self.pageBlock(cid);
        }
    }];
    
    [self.jianJieTableView reloadData];
}

-(void)pageSelectWithBlock:(pageSeleBlock)block
{
    self.pageBlock = block;
}

-(WJSegmentMenu *)topMenu
{
    if (!_topMenu) {
        _topMenu = [[WJSegmentMenu alloc] initWithFrame:CGRectMake(0, 0, self.width, 30)];
        [_topMenu segmentWithTitles:@[@"简介",@"评论"]];
        _topMenu.delegate = self;
        [self addSubview:_topMenu];
    }
    return _topMenu;
}

-(void)segmentWithIndex:(NSInteger)index title:(NSString *)title
{
    [self.scrollView setContentOffset:CGPointMake(index*self.scrollView.width, 0) animated:YES];
}

-(UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
        _scrollView.size = CGSizeMake(self.width, self.height-30);
        _scrollView.top = 30;
        _scrollView.contentSize = CGSizeMake(self.width*2, 0);
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    return _scrollView;
}

-(UITableView *)jianJieTableView
{
    if (!_jianJieTableView) {
        _jianJieTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.width, self.scrollView.height) style:UITableViewStylePlain];
        _jianJieTableView.backgroundColor = kBgColor;
        _jianJieTableView.delegate = self;
        _jianJieTableView.dataSource = self;
        [self.scrollView addSubview:_jianJieTableView];
        
        _jianJieTableView.tableFooterView = [UIView new];
        
        [_jianJieTableView registerClass:[RelateCell class] forCellReuseIdentifier:@"relate"];
    }
    return _jianJieTableView;
}

-(UITableView *)conmmentTableView
{
    if (!_conmmentTableView) {
        _conmmentTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.scrollView.width, 0, self.scrollView.width, self.scrollView.height) style:UITableViewStylePlain];
        _conmmentTableView.backgroundColor = kBgColor;
        _conmmentTableView.delegate = self;
        _conmmentTableView.dataSource = self;
        [self.scrollView addSubview:_conmmentTableView];
        
        _conmmentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_conmmentTableView registerClass:[ReplyCell class] forCellReuseIdentifier:@"reply"];
        [_conmmentTableView registerClass:[RreplyCell class] forCellReuseIdentifier:@"Rreply"];
        
    }
    return _conmmentTableView;
}

-(NSMutableArray *)replyArray
{
    if (!_replyArray) {
        _replyArray = [NSMutableArray array];
    }
    return _replyArray;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.scrollView) {
        CGFloat offSet = scrollView.contentOffset.x;
        [self.topMenu scrollWithOffSet:offSet];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
