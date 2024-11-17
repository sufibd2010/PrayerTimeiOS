//
//  SalahTimesBundle.swift
//  SalahTimes
//
//  Created by Md. Abu Sufian Sufi on 11/17/24.
//

import WidgetKit
import SwiftUI

@main
struct SalahTimesBundle: WidgetBundle {
    var body: some Widget {
        SalahTimes()
        SalahTimesControl()
        SalahTimesLiveActivity()
    }
}
