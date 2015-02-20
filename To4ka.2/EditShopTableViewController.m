//
//  EditShopTableViewController.m
//  To4ka.2
//
//  Created by Air on 22.01.15.
//  Copyright (c) 2015 Bogdanov. All rights reserved.
//

#import "EditShopTableViewController.h"
#import "ShopsTableViewController.h"
#include <QuartzCore/QuartzCore.h>


@import AddressBook;

@interface EditShopTableViewController () <UITextFieldDelegate>

@end

@implementation EditShopTableViewController

@synthesize editShop;
@synthesize hideSecondPhoneSection;


-(void)viewDidLoad {
    
    [super viewDidLoad];
    
// [Get permission to access the AddressBook ...
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(nil, nil);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (!granted) {
                return;
            }
        });
    }
    CFRelease (addressBookRef);
//  ...Get permission to access the AddressBook]
    
    if ([_shopSecondPhoneNumber.text = editShop.shopSecondPhoneNumber length] == 0){
        hideSecondPhoneSection = YES;
    } else{
        hideSecondPhoneSection = NO;
    };
    
    for (UITextField *anyTextField in self.arreyTextField) {
        anyTextField.delegate = self;
    }
    
    _shopName.enabled = NO;
    _shopPhoneNumber.enabled = NO;
    _shopSecondPhoneNumber.enabled = NO;
    _shopEmail.enabled = NO;
    _shopNoteView.editable = NO;
    
    self.addSecondShopPhoneNumberButtone.hidden = YES;
    
    _shopName.borderStyle = UITextBorderStyleNone;
    _shopPhoneNumber.borderStyle = UITextBorderStyleNone;
    _shopSecondPhoneNumber.borderStyle = UITextBorderStyleNone;
    _shopEmail.borderStyle = UITextBorderStyleNone;
    
    _shopName.text = editShop.shopName;
    _shopPhoneNumber.text = editShop.shopPhoneNumber;
    _shopSecondPhoneNumber.text = editShop.shopSecondPhoneNumber;
    _shopEmail.text = editShop.shopEmail;
    _shopNoteView.text = editShop.shopNote;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark - AddressBook Button AddShopAddressBook

-(void)cantAddContactAlert{
    
    UIAlertView *cantAddContactAlert = [[UIAlertView alloc]
                                        initWithTitle: @"Cannot Add Contact"
                                        message: @"You must give the app permission to add the contact first."
                                        delegate:nil
                                        cancelButtonTitle: @"OK"
                                        otherButtonTitles: nil];
    [cantAddContactAlert show];
}

-(void)addToPhoneBook {
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted){
        //1 This checks to see if the user has either denied your app access to the AddressBook in the past, or it is restricted because of parental controls. In this case, all you can do is inform the user that you can’t add the contact because the app does not have permission.
        [self cantAddContactAlert];
        NSLog(@"Permission AddressBook Denied");
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        //2 This checks to see if the user has already given your app permission to use their AddressBook. In this case, you are free to modify the AddressBook however you want.
        [self createGroupAddressBook];
        [self addShopToContacts];
        NSLog(@"Permission AddressBook Authorized");
    }
    else{ //ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined
        //3 This checks to see if the user hasn’t decided yet whether not to give permission to your app.
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            if (!granted){
                //4 executes only if the user denies permission when your app asks.
                [self cantAddContactAlert];
                // NSLog(@"Just denied");
                return;
            }
            //5 executes if the user gives permission for you to use the AddressBook.
            NSLog(@"Just Authorized AddressBook");
        });
        NSLog(@"Not Determined AddressBook");
    }
}

#pragma mark -
#pragma mark - AddressBook Create Group Phone Book


-(void)createGroupAddressBook {
    
    NSString *newGroupName = @"To4ka";
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
    
    if (addressBook){
        BOOL groupNameIsEqual = NO;
        
        CFArrayRef allGroups = ABAddressBookCopyArrayOfAllGroups(addressBook);
        if (allGroups){
            for (int index=0; index<CFArrayGetCount(allGroups); index++){
                ABRecordRef group = CFArrayGetValueAtIndex(allGroups, index);
                NSString *groupName = (__bridge NSString *)ABRecordCopyValue(group,
                                                                             kABGroupNameProperty);
                
                if ([groupName isEqualToString:newGroupName]) {
                    groupNameIsEqual = YES;
                    break;
                }
            }
        }
        CFRelease(allGroups);
        
        if (groupNameIsEqual) {
            NSLog(@"This Group in AddressBook Already Exists");
        }
        else {
            ABRecordRef group = ABGroupCreate();
            if (!group){
                NSLog(@"Error Creating Group in AddressBook");
                return;
            }
            
            CFErrorRef error = nil;
            BOOL couldSetGroupName = ABRecordSetValue(group,
                                                      kABGroupNameProperty,
                                                      (__bridge CFStringRef)newGroupName,
                                                      &error);
            if (couldSetGroupName){
                if (ABAddressBookAddRecord(addressBook, group, &error)){
                    NSLog(@"New Group in AddressBook Added");
                    [self saveAddressBook:addressBook];
                } else {
                    NSLog(@"Unable Add New Group in AddressBook");
                }
            }
            else {
                NSLog(@"Error Installing Name Group");
            }
        }
        CFRelease(addressBook);
    }
}

#pragma mark -
#pragma mark - AddressBook Shop Info For Phone Book


-(void)addShopToContacts {
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
    
    if (addressBook) {
        
        NSString *phone = _shopPhoneNumber.text;
        NSString *shop = _shopName.text;
        NSString *note = _shopNoteView.text;
        NSString *secondPhone = _shopSecondPhoneNumber.text;
        NSString *email = _shopEmail.text;
        
        ABRecordRef person = ABPersonCreate();
        if (!person) {
            NSLog(@"Can Not Create Shop");
            return;
        }
        
        CFErrorRef error = nil;
        
        
        BOOL couldSetCompanyName = ABRecordSetValue(person,
                                                    kABPersonOrganizationProperty,
                                                    (__bridge CFStringRef) shop,
                                                    &error);
        BOOL couldSetNotes = ABRecordSetValue(person,
                                              kABPersonNoteProperty,
                                              (__bridge CFStringRef) note,
                                              &error);

        
        ABMutableMultiValueRef emailSet = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel (emailSet,
                                      (__bridge CFStringRef) email,
                                      kABWorkLabel,
                                      NULL);
        ABRecordSetValue(person, kABPersonEmailProperty, emailSet, nil);
        CFRelease(emailSet);
        
        ABMutableMultiValueRef phones = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(phones,
                                     (__bridge CFStringRef)phone,
                                     kABPersonPhoneMainLabel,
                                     NULL);
        ABMultiValueAddValueAndLabel(phones,
                                     (__bridge CFStringRef)secondPhone,
                                     kABPersonPhoneMobileLabel,
                                     NULL);
        
        BOOL couldSetPhoneNumber = ABRecordSetValue(person,
                                                    kABPersonPhoneProperty,
                                                    phones,
                                                    &error);
        CFRelease(phones);
        
        if (couldSetCompanyName && couldSetPhoneNumber && couldSetNotes && emailSet) {
            NSLog(@"Connection Whith AddressBook");
        }
        
        if (ABAddressBookAddRecord(addressBook, person, &error)) {
            NSLog(@"Shop Added To AddressBook");
        }

        [self saveAddressBook:addressBook];
        
        //Add to Group
        CFArrayRef allGroups = ABAddressBookCopyArrayOfAllGroups(addressBook);
        if (allGroups){
            for (int index=0; index<CFArrayGetCount(allGroups); index++){
                ABRecordRef group = CFArrayGetValueAtIndex(allGroups, index);
                NSString *groupName = (__bridge NSString *)
                ABRecordCopyValue(group, kABGroupNameProperty);
                
                if ([groupName isEqualToString:@"To4ka"]) {
                    if (ABGroupAddMember(group, person, &error)) {
                        
                        NSLog(@"Shop Added To Group");
                    }
                    else {
                        NSLog(@"Failed! Shop Failed Add To Group");
                    }
                    break;
                }
            }
        }
        CFRelease(allGroups);
        [self saveGroupAddressBook:addressBook];
        //Adding In Group
        CFRelease(addressBook);
    }
}

#pragma mark -
#pragma mark - AddressBook Save Method To Phone Book Group & Person


-(void)saveAddressBook:(ABAddressBookRef)addressBook {
    
    if (ABAddressBookHasUnsavedChanges(addressBook)) {
        CFErrorRef error = nil;
        if (ABAddressBookSave(addressBook, &error)){
            
            NSLog(@"Shop Saved To AddressBook");
        }
        else {
            UIAlertView *cantDisAddContactAlert = [[UIAlertView alloc]
                                                   initWithTitle: @"Sorry"
                                                   message: @"Can Not Add Shop To AddressBook"
                                                   delegate:nil
                                                   cancelButtonTitle: @"OK"
                                                   otherButtonTitles: nil];
            [cantDisAddContactAlert show];
        }
    }
}

-(void)saveGroupAddressBook:(ABAddressBookRef)addressBook {
    
    if (ABAddressBookHasUnsavedChanges(addressBook)) {
        CFErrorRef error = nil;
        
        if (ABAddressBookSave(addressBook, &error)){
            NSLog(@"Shop in Group Added To AddressBook");
        }
        else {
            NSLog(@"Can Not Add Shop in Group To AddressBook");
        }
    }
}


#pragma mark -
#pragma mark - Hiden Second Phone Number Section


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
    {
    if (section == 2 && hideSecondPhoneSection) {
        return 0;
    }
    else {
        return [super tableView:tableView heightForHeaderInSection:section];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 2 && hideSecondPhoneSection) {
        cell.hidden = YES;
        return 0;
    } else {
        cell.hidden = NO;
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

#pragma mark -
#pragma mark - Button Add Second Phone Number Button


-(IBAction)addSecondPhoneNumber:(id)sender {
    
    hideSecondPhoneSection = NO;
    [self.tableView reloadData];
    [self.shopSecondPhoneNumber becomeFirstResponder];
    self.addSecondShopPhoneNumberButtone.hidden = YES;
}

#pragma mark -
#pragma mark - Check Text Field for Validation Email


-(BOOL)checkEmailTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSCharacterSet *validation = [NSCharacterSet characterSetWithCharactersInString:@"?±~!#$%^,/|&*()<>=+{}][:;'\" \\"];
    NSArray * components = [string componentsSeparatedByCharactersInSet:validation];
    
    if ([components count] > 1) {
        return NO;
    }
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (([newString rangeOfString:@"@"].length) < 1) {
        self.atPresent = NO;
    }
    if ([newString length] < 2 && [string isEqualToString:@"@"]) {
        return NO;
    }
    if ([newString length] > 30) {
        return NO;
    }
    if (self.atPresent && [string isEqualToString:@"@"]) {
        return NO;
    }
    if ([string isEqualToString:@"@"]) {
        self.atPresent = YES;
    }
    textField.text = newString;
    return NO;
}

#pragma mark -
#pragma mark - Check Text Field for Validation Phone


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    BOOL yesOrNot = TRUE;
    if ([textField isEqual:self.shopPhoneNumber]) {
        yesOrNot = [self checkPhoneTextField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    if ([textField isEqual:self.shopSecondPhoneNumber]) {
        yesOrNot = [self checkPhoneTextField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    if ([textField isEqual:self.shopEmail]) {
        yesOrNot = [self checkEmailTextField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    return yesOrNot;
}

#pragma mark -
#pragma mark - UITextFieldDelegate Phone Number


-(BOOL)checkPhoneTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSCharacterSet* validationSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSArray* components = [string componentsSeparatedByCharactersInSet:validationSet];
    
    if ([components count] > 1) {
        return NO;
    }
    NSString* newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSArray* validComponents = [newString componentsSeparatedByCharactersInSet:validationSet];
    newString = [validComponents componentsJoinedByString:@""];
    NSMutableString* resultString = [NSMutableString string];
    
    static const int localNumberMaxLenght = 7;
    static const int areaCodeMaxLenght = 3;
    static const int countryMaxLenght = 2;
    
    if ([newString length] > localNumberMaxLenght + areaCodeMaxLenght + countryMaxLenght) {
        return NO;
    }
    
    NSInteger localNumberLenght = MIN([newString length], localNumberMaxLenght);
    
    if (localNumberLenght > 0) {
        
        NSString* number = [newString substringFromIndex:(int)[newString length] - localNumberLenght];
        
        [resultString appendString:number];
        
        if ([resultString length] > 3) {
            [resultString insertString:@"-" atIndex:3];
        }
    }
    if ([newString length] > localNumberMaxLenght) {
        
        NSInteger areaCodeLenght = MIN((int)[newString length] - localNumberMaxLenght, areaCodeMaxLenght);
        NSRange areaRange = NSMakeRange((int)[newString length] - localNumberMaxLenght - areaCodeLenght, areaCodeLenght);
        NSString* area = [newString substringWithRange:areaRange];
        area = [NSString stringWithFormat:@"(%@) ", area];
        [resultString insertString:area atIndex:0];
        
    }
    if ([newString length] > localNumberMaxLenght + areaCodeMaxLenght) {
        
        NSInteger countryCodeLenght = MIN((int)[newString length] - localNumberMaxLenght - areaCodeMaxLenght, countryMaxLenght);
        
        NSRange countryCodeRange = NSMakeRange(0, countryCodeLenght);
        
        NSString* countryCode = [newString substringWithRange:countryCodeRange];
        
        countryCode = [NSString stringWithFormat:@"+%@ ", countryCode];
        [resultString insertString:countryCode atIndex:0];
    }
    textField.text = resultString;
    return NO;
}

#pragma mark -
#pragma mark - Return key


-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField isEqual:self.shopName]) {
        [self.shopPhoneNumber becomeFirstResponder];
    }
    if ((self.hideSecondPhoneSection == YES) &&
        ([textField isEqual:self.shopPhoneNumber])){
        [self.shopEmail becomeFirstResponder];
    }
    else if ((self.hideSecondPhoneSection == NO) &&
             ([textField isEqual:self.shopPhoneNumber])){
        [self.shopSecondPhoneNumber becomeFirstResponder];
    }
    if ([textField isEqual:self.shopSecondPhoneNumber]) {
        [self.shopEmail becomeFirstResponder];
    }
    if ([textField isEqual:self.shopEmail]) {
        [self.shopNoteView becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark -
#pragma mark - Check For Same Shop & PhoneNumber Length For AddressBook

-(void)checkShopPhoneNumber{
    
    if (!([_shopPhoneNumber.text length] > 0 || [_shopSecondPhoneNumber.text length] > 0)) {
        NSLog(@"Empty Phone Number");
    }
    else {
        
        [self addToPhoneBook];
    }
}

-(NSManagedObjectContext*) managedObjectContext {
    return [(AppDelegate*)[[UIApplication sharedApplication]delegate]managedObjectContext];
}

-(BOOL)uniqueEntityExistsWithEnityName {
    
    BOOL returnValue = NO;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Shop"];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"shopName = [cd] %@", _shopName.text];
    
//    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"shopName = [cd] %@ AND shopPhoneNumber = [cd] %@ AND shopSecondPhoneNumber = [cd] %@ AND shopEmail = [cd] %@ AND shopNote = [cd] %@",_shopName.text, _shopPhoneNumber.text, _shopSecondPhoneNumber.text, _shopEmail.text, _shopNoteView.text];
    
    NSSortDescriptor *shop = [[NSSortDescriptor alloc] initWithKey:@"shopName" ascending:YES];
    
    [request setSortDescriptors: @[shop]];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    NSLog(@"request = %@",predicate);
    
    if (!matches) {
        NSLog(@"Error: Couldn't execute fetch request %@", error);
        
    }
    else if([matches count] > 1) {
        
        NSString *existShop = [NSString stringWithFormat:@"Could Be Only One %@ Shop", _shopName.text];
        
        UIAlertView *exist = [[UIAlertView alloc]initWithTitle:@"Shop Exists in Your Records"
                                                       message:existShop
                                                      delegate:nil
                                             cancelButtonTitle:@"Ok"
                                             otherButtonTitles:nil];
        [exist show];
        
        NSLog(@"Error: Have more than %lu records",
              (unsigned long)[matches count]);
        returnValue = YES;
    }
    else {
        
        NSLog(@"%lu object in record", (unsigned long)[matches count]);
        
        [self oldShopDelete];
        [self checkShopPhoneNumber];
        
        editShop.shopName = _shopName.text;
        editShop.shopPhoneNumber = _shopPhoneNumber.text;
        editShop.shopSecondPhoneNumber = _shopSecondPhoneNumber.text;
        editShop.shopEmail = _shopEmail.text;
        editShop.shopNote = _shopNoteView.text;
        
        [super saveAndDissmiss];
        
        returnValue = YES;
    }
    return returnValue;
}

#pragma mark -
#pragma mark - oldShopDelete

-(void)oldShopDelete{

    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
    
    CFArrayRef groups = ABAddressBookCopyArrayOfAllGroups(addressBook);
    CFIndex numGroups = CFArrayGetCount(groups);
    for(CFIndex idx=0; idx<numGroups; ++idx) {
        
        ABRecordRef groupItem = CFArrayGetValueAtIndex(groups, idx);
        
        NSString *name = (__bridge NSString *)(ABRecordCopyValue(groupItem, kABGroupNameProperty));
        if ([name isEqualToString:@"To4ka"])
            
        {
        CFArrayRef members = ABGroupCopyArrayOfAllMembers(groupItem);
        if(members) {
            NSUInteger count = CFArrayGetCount(members);
            for(NSUInteger idx=0; idx<count; ++idx) {
                
                ABRecordRef person = CFArrayGetValueAtIndex(members, idx);
                NSString *shopName = (__bridge NSString *)ABRecordCopyValue(person,
                                                        kABPersonOrganizationProperty);
                NSString *lookingShopName = [NSString stringWithFormat:@"%@",editShop.shopName];
                
                if ([shopName isEqualToString:lookingShopName]) {
                    ABAddressBookRemoveRecord(addressBook, person,nil);
                    NSLog(@"Delated");
                }
            }
            CFRelease(members);
        }
        }
    }
    ABAddressBookSave(addressBook, nil);
    CFRelease(groups);
    CFRelease(addressBook);
}


#pragma mark -
#pragma mark - Cance And Save

-(IBAction)cancel:(UIBarButtonItem *)sender {
    [super cancelAndDismiss];
}

-(IBAction)editSave:(UIBarButtonItem *)sender {
    if ([_editSaveButton.title isEqualToString:@"Edit"]) {
        NSLog(@"Edit Button Has Been Pressed!");
        
        [self setTitle:@"Edit Shop"];
        
        _shopName.enabled = YES;
        _shopPhoneNumber.enabled = YES;
        _shopSecondPhoneNumber.enabled = YES;
        _shopEmail.enabled = YES;
        _shopNoteView.editable = YES;
        
        if (!([_shopSecondPhoneNumber.text = editShop.shopSecondPhoneNumber length] == 0)){
            self.addSecondShopPhoneNumberButtone.hidden = YES;
        } else{
            self.addSecondShopPhoneNumberButtone.hidden = NO;
        };
        
        [self.tableView reloadData];
        
        _shopName.borderStyle = UITextBorderStyleRoundedRect;
        _shopPhoneNumber.borderStyle = UITextBorderStyleRoundedRect;
        _shopSecondPhoneNumber.borderStyle = UITextBorderStyleRoundedRect;
        _shopEmail.borderStyle = UITextBorderStyleRoundedRect;
        
        _editSaveButton.title = @"Save";
        
        [self textViewStyle];
    }
    else {
        
        _shopName.enabled = NO;
        _shopPhoneNumber.enabled = NO;
        _shopSecondPhoneNumber.enabled = NO;
        _shopEmail.enabled = NO;
        _shopNoteView.editable = NO;
        
        _shopName.borderStyle = UITextBorderStyleNone;
        _shopPhoneNumber.borderStyle = UITextBorderStyleNone;
        _shopSecondPhoneNumber.borderStyle = UITextBorderStyleNone;
        _shopEmail.borderStyle = UITextBorderStyleNone;
        
        _editSaveButton.title = @"Edit";
        
        if ([_shopName.text length] == 0)
        {
            UIAlertView *empty = [[UIAlertView alloc]initWithTitle:@"Fill Up The Form"
                                                           message:@""
                                                          delegate:nil
                                                 cancelButtonTitle:@"Ok"
                                                 otherButtonTitles:nil];
            [empty show];
        }
        else {
            [self uniqueEntityExistsWithEnityName];
        }
    }
}

#pragma mark -
#pragma mark - TextView Style


-(void)textViewStyle{
    
    [[self.shopNoteView layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [[self.shopNoteView layer] setBorderWidth:.4];
    [[self.shopNoteView layer] setCornerRadius:8.0f];
}

@end
