//
//  MonthlyWidgetBundle.swift
//  MonthlyWidget
//
//  Created by Francois Lambert on 4/29/24.
//

import WidgetKit
import SwiftUI

@main
struct MonthlyWidgetBundle: WidgetBundle {
    var body: some Widget {
        MonthlyWidget()
        MonthlyWidgetLiveActivity()
    }
}
