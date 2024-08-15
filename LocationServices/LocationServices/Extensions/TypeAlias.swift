//
//  TypeAlias.swift
//  LocationServices
//
// Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
// SPDX-License-Identifier: MIT-0

import UIKit

public typealias VoidHandler = (() -> Void)
public typealias BoolHandler = ((Bool) -> Void)
public typealias StringHandler = ((String) -> Void)
public typealias IntHandler = ((Int) -> Void)
public typealias DoubleHandler = ((Double) -> Void)
public typealias Handler<T> = ((T) -> Void)
