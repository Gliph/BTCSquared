/**
 * The MIT License (MIT)
 *
 * Copyright (c) 2013 Joakim Fernstad
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 **/

//
//  BTC2PeripheralManager.h
//  BTC2
//
//  Created by Joakim Fernstad on 5/17/13.
//  Copyright (c) 2013 Joakim Fernstad. Releases under the MIT License.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class BTC2CentralSession;
@class BTC2PeripheralManager;
@class BTC2WriteQueue;
@class BTC2WalletModel;
@class BTC2IdentityModel;
@class BTC2ServiceProviderModel;

@interface BTC2PeripheralManager : NSObject<CBPeripheralManagerDelegate>
@property (nonatomic, readonly) CBPeripheralManager* peripheralManager;
@property (nonatomic, strong) BTC2CentralSession* connectedSession; // Can only have one
@property (nonatomic, assign) BOOL useEncryption;
@property (nonatomic, readonly) CBMutableService* walletService;
@property (nonatomic, readonly) CBMutableService* idService;
@property (nonatomic, readonly) CBMutableService* providerService;
@property (nonatomic, readonly) BTC2WriteQueue* writeQueue;

// Wallet service
@property (nonatomic, strong) BTC2WalletModel* wallet;

// ID Service
@property (nonatomic, strong) BTC2IdentityModel* identity;

// Service provider service
@property (nonatomic, strong) BTC2ServiceProviderModel* serviceProvider;

+ (BTC2PeripheralManager*)manager;
-(void)enqueueData:(NSData*)data forCharacteristic:(CBMutableCharacteristic*)characteristic;
-(void)startAdvertising;
-(void)stopAdvertising;
-(void)cleanup;
@end
