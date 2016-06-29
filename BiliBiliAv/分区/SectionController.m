//
//  SectionController.m
//  BiliBiliAv
//
//  Created by 胡亚刚 on 16/5/10.
//  Copyright © 2016年 hu yagang. All rights reserved.
//

#import "SectionController.h"
#import "SectionItemCell.h"
#import "SectionItem.h"
#import "YYModel.h"

#define kItemDataFileName @"SectionConfig.plist"
@interface SectionController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic,strong) UICollectionView * collectionView;
@property (nonatomic,copy) NSMutableArray * itemArray;
@end

@implementation SectionController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView reloadData];
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.itemArray.count;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 20, 5, 20);
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"sectionCell";
    SectionItemCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    SectionItem * item = self.itemArray[indexPath.row];
    cell.item = item;
    NSLog(@"%@",item.name);
    return cell;
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    // NSLog(@"当前item == %ld",(long)indexPath.row);
}


-(UICollectionView *)collectionView
{
    if (!_collectionView) {
        CGFloat width = (self.view.width-4*20)/3;
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize=CGSizeMake(width,width*1.1);
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        
        _collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height-64-49) collectionViewLayout:flowLayout];
        _collectionView.dataSource=self;
        _collectionView.delegate=self;
        _collectionView.backgroundColor = kBgColor;
        
        [self.view addSubview:_collectionView];
        
        [_collectionView registerClass:[SectionItemCell class] forCellWithReuseIdentifier:@"sectionCell"];
    }
    return _collectionView;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.navigationController.viewControllers.count==1) {
        self.navigationController.navigationBar.hidden = YES;
    }else{
        self.navigationController.navigationBar.hidden = NO;
    }
}

-(NSMutableArray *)itemArray
{
    if (!_itemArray) {
        NSString * path = [[NSBundle mainBundle] pathForResource:kItemDataFileName ofType:nil];
        _itemArray = [NSMutableArray array];
        NSArray * list = [NSArray arrayWithContentsOfFile:path];
        for (NSDictionary * dic in list) {
            SectionItem * item = [SectionItem yy_modelWithDictionary:dic];
            [_itemArray addObject:item];
        }
    }
    return _itemArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
