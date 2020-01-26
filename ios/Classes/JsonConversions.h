// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <NMapsMap/NMapsMap.h>

@interface FLTNaverMapJsonConversions : NSObject
+ (bool)toBool:(NSNumber *)data;
+ (int)toInt:(NSNumber *)data;
+ (double)toDouble:(NSNumber *)data;
+ (float)toFloat:(NSNumber *)data;
+ (NMGLatLng *)toLocation:(NSArray *)data;
+ (CGPoint)toPoint:(NSArray *)data;
+ (NSArray *)positionToJson:(NMGLatLng *)position;
+ (UIColor *)toColor:(NSNumber *)data;
+ (NSArray<CLLocation *> *)toPoints:(NSArray *)data;
@end