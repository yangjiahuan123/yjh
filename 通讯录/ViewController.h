//
//  ViewController.h
//  通讯录
//
//  Created by mac on 2016/11/29.
//  Copyright © 2016年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ContactsUI/CNContactViewController.h>
#import <ContactsUI/CNContactPickerViewController.h>

@interface ViewController : UIViewController<CNContactViewControllerDelegate,CNContactPickerDelegate>
@end

