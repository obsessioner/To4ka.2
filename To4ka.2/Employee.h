//
//  Employee.h
//  To4ka.2
//
//  Created by Air on 03.02.15.
//  Copyright (c) 2015 Bogdanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Shop;

@interface Employee : NSManagedObject

@property (nonatomic, retain) NSDate * employeeDateOfBirth;
@property (nonatomic, retain) NSString * employeeEmail;
@property (nonatomic, retain) NSString * employeeFirstName;
@property (nonatomic, retain) NSString * employeeLastName;
@property (nonatomic, retain) NSString * employeeNote;
@property (nonatomic, retain) NSString * employeePhoneNumber;
@property (nonatomic, retain) NSString * employeeSecondPhoneNumber;
@property (nonatomic, retain) NSString * employeeShop;
@property (nonatomic, retain) NSSet *shop;
@end

@interface Employee (CoreDataGeneratedAccessors)

- (void)addShopObject:(Shop *)value;
- (void)removeShopObject:(Shop *)value;
- (void)addShop:(NSSet *)values;
- (void)removeShop:(NSSet *)values;

@end
