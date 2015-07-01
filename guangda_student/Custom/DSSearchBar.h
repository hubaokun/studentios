//
//  DSSearchBar.h
//  wedding
//
//  Created by Jianyong Duan on 14/11/21.
//  Copyright (c) 2014年 daoshun. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DSSearchBarDelegate;

@interface DSSearchBar : UIView

@property(nonatomic,assign) id<DSSearchBarDelegate> delegate;
@property(nonatomic,copy)   NSString               *text;
@property(nonatomic,copy)   NSString               *placeholder;

@end

@protocol DSSearchBarDelegate <NSObject>

@optional

- (BOOL)searchBarShouldBeginEditing:(DSSearchBar *)searchBar;                      // return NO to not become first responder
- (void)searchBarTextDidBeginEditing:(DSSearchBar *)searchBar;                     // called when text starts editing
- (BOOL)searchBarShouldEndEditing:(DSSearchBar *)searchBar;                        // return NO to not resign first responder
- (void)searchBarTextDidEndEditing:(DSSearchBar *)searchBar;                       // called when text ends editing
- (void)searchBar:(DSSearchBar *)searchBar textDidChange:(NSString *)searchText;   // called when text changes (including clear)
- (BOOL)searchBar:(DSSearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text NS_AVAILABLE_IOS(3_0); // called before text changes

- (void)searchBarSearchButtonClicked:(DSSearchBar *)searchBar;                     // called when keyboard search button pressed
- (void)searchBarCancelButtonClicked:(DSSearchBar *)searchBar;                     // called when cancel button pressed

- (void)searchBar:(DSSearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope NS_AVAILABLE_IOS(3_0);

@end