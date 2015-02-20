//
//  Store.h
//  To4ka.2
//
//  Created by Air on 23.01.15.
//  Copyright (c) 2015 Bogdanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Store : NSManagedObject

@property (nonatomic, retain) NSString * storeName;
@property (nonatomic, retain) NSString * storePhoneNumber;
@property (nonatomic, retain) NSString * storeSecondPhoneNumber;
@property (nonatomic, retain) NSString * storeEmail;
@property (nonatomic, retain) NSString * storeNote;

@end
