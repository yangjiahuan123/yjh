//
//  ViewController.m
//  通讯录
//
//  Created by mac on 2016/11/29.
//  Copyright © 2016年 mac. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
}
@property(nonatomic,strong)CNContactStore *contactStore;//创建获取数据的对象
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0/255.0  green:201/255.0 blue:87/255.0 alpha:1];
    
}
- (IBAction)newContactClicked:(id)sender {
    [self saveNewContact];
}
- (IBAction)currentContactClicked:(id)sender {
    [self saveExistContact];
}

- (void)saveNewContact{
    //1.创建Contact对象，必须是可变的
    CNMutableContact *contact = [[CNMutableContact alloc] init];
    //2.为contact赋值，setValue4Contact中会给出常用值的对应关系
    [self setValue4Contact:contact existContect:NO];
    //3.创建新建好友页面
    CNContactViewController *controller = [CNContactViewController viewControllerForNewContact:contact];
    //实现代理
    controller.delegate = self;
    //4.跳转页面
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navigation animated:YES completion:^{
        
    }];
    
}
//CNContactViewController：展示联系人详细信息的controller

//保存现有联系人实现
- (void)saveExistContact{
    //1.跳转到联系人选择页面，注意这里没有使用UINavigationController
    CNContactPickerViewController *controller = [[CNContactPickerViewController alloc] init];
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}
//CNContactPickerViewController：展示联系人列表的controller

#pragma mark - CNContactViewControllerDelegate
- (void)contactViewController:(CNContactViewController *)viewController didCompleteWithContact:(nullable CNContact *)contact{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - CNContactPickerDelegate
//2.实现点选的代理，其他代理方法根据自己需求实现
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact{
    [picker dismissViewControllerAnimated:YES completion:^{
        //3.copy一份可写的Contact对象，这里要注意只能用mutableCopy
        CNMutableContact *c = [contact mutableCopy];
        //4.为contact赋值
        [self setValue4Contact:c existContect:YES];
        //5.跳转到新建联系人页面
        CNContactViewController *controller = [CNContactViewController viewControllerForNewContact:c];
        controller.delegate = self;
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentViewController:navigation animated:YES completion:^{
        }];
    }];
}
//实现CNContactPickerDelegate代理方法
//（1）-contactPickerDidCancel:

//这个是点击右上角的cancel时候触发的，而不是picker的所有dismiss动作中都会触发。在多选模式下，cancel在done的左侧。

//其他四个代理方法只要实现其中任一一个就行了。分别为单选和多选两组，都实现的时候，多选优先执行，单选不执行。特别要注意的是predicateForEnablingContact，predicateForSelectionOfContact，predicateForSelectionOfProperty这三组会影响它们的动作。predicateForEnablingContact返回YES的联系人才是可交互的，不设置的时候都是可交互的。
//
//（2）- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(nonnull CNContact *)contact
//
//只实现该方法时，如果predicateForSelectionOfContact没设置或者命中，则将会在点击联系人列表或该联系人时触发。如果不命中则会触发默认动作，也即是进入联系人详细页。
//
//（3）- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContacts:(NSArray<CNContact *> *)contacts
//
//只实现该方法时，联系人列表进入多选模式，该方法在点击done按钮时触发。然而并不受predicateForSelectionOfContact影响。
//
//
//（4）- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty
//
//只实现该方法时，可以进入到联系人详情页面，如果predicateForSelectionOfProperty没设置或者命中，则将会在点击联系人某个property时触发并返回该contactProperty。如果不命中则会触发默认动作，也即是打电话，发邮件，Facebook等。
//
//（5）- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperties:(NSArray<CNContactProperty *> *)contactProperties
//
//只实现该方法时，停留在多选模式下的联系人列表页面，如果predicateForSelectionOfProperty没设置或者命中，则该联系人能被选中，在点击done按钮的时候触发，返回的contactProperties中只包含命中的contactProperties。没设置的话返回空。
//
//设置要保存的contact对象
- (void)setValue4Contact:(CNMutableContact *)contact existContect:(BOOL)exist{
    if (!exist) {
        //名字和头像
        contact.nickname = @"昵称";
        //        UIImage *logo = [UIImage imageNamed:@"..."];
        //        NSData *dataRef = UIImagePNGRepresentation(logo);
        //        contact.imageData = dataRef;
    }
    //电话,每一个CNLabeledValue都是有要求的，如何选择，可以在头文件里面查找。
    CNLabeledValue *phoneNumber = [CNLabeledValue labeledValueWithLabel:CNLabelPhoneNumberMobile value:[CNPhoneNumber phoneNumberWithStringValue:@"18888888888"]];
    if (!exist) {
        contact.phoneNumbers = @[phoneNumber];
    }
    //现有联系人情况
    else{
        if ([contact.phoneNumbers count] >0) {
            NSMutableArray *phoneNumbers = [[NSMutableArray alloc] initWithArray:contact.phoneNumbers];
            [phoneNumbers addObject:phoneNumber];
            contact.phoneNumbers = phoneNumbers;
        }else{
            contact.phoneNumbers = @[phoneNumber];
        }
    }
    
    //网址:CNLabeledValue *url = [CNLabeledValue labeledValueWithLabel:@"" value:@""];
    //邮箱:CNLabeledValue *mail = [CNLabeledValue labeledValueWithLabel:CNLabelWork value:self.poiData4Save.mail];
    
    //特别说明，PostalAddress对应的才是地址
    CNMutablePostalAddress *address = [[CNMutablePostalAddress alloc] init];
    address.state = @"四川省";
    address.city = @"成都市";
    address.postalCode = @"650000";
    //具体地址
    address.street = @"百叶路1号";
    //生成的上面地址的CNLabeledValue，其中可以设置类型CNLabelWork等等
    CNLabeledValue *addressLabel = [CNLabeledValue labeledValueWithLabel:CNLabelWork value:address];
    if (!exist) {
        contact.postalAddresses = @[addressLabel];
    }else{
        if ([contact.postalAddresses count] >0) {
            NSMutableArray *addresses = [[NSMutableArray alloc] initWithArray:contact.postalAddresses];
            [addresses addObject:addressLabel];
            contact.postalAddresses = addresses;
        }else{
            contact.postalAddresses = @[addressLabel];
        }
    }
}



@end

