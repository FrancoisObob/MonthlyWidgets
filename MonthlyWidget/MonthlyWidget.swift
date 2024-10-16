//
//  MonthlyWidget.swift
//  MonthlyWidget
//
//  Created by Francois Lambert on 4/29/24.
//

import AppIntents
import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> DayEntry {
        DayEntry(date: Date(), showFunFont: false)
    }

    func snapshot(for configuration: ChangeFontIntent, in context: Context) async -> DayEntry {
        DayEntry(date: Date(), showFunFont: false)
    }
    
    func timeline(for configuration: ChangeFontIntent, in context: Context) async -> Timeline<DayEntry> {

        var entries: [DayEntry] = []

        // Generate a timeline consisting of seven entries a day apart, starting from the current date.
        let currentDate = Date()
        for dayOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate)!
            let startOfDate = Calendar.current.startOfDay(for: entryDate)
            let entry = DayEntry(date: startOfDate, showFunFont: configuration.funFont ?? false)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct DayEntry: TimelineEntry {
    let date: Date
    let showFunFont: Bool

    init(date: Date, showFunFont: Bool) {
        self.date = date
        self.showFunFont = showFunFont
    }

    init(day: Int, month: Int, showFunFont: Bool = false) {
        let components = DateComponents(calendar: Calendar.current,
                                        year: 2024,
                                        month: month,
                                        day: day)
        self.date = Calendar.current.date(from: components)!
        self.showFunFont = showFunFont
    }
}

struct MonthlyWidgetEntryView : View {
    @Environment(\.showsWidgetContainerBackground) var showsBackground
    var entry: DayEntry
    var config: MonthConfig
    let funFontName = "Chalkduster"

    init(entry: DayEntry) {
        self.entry = entry
        self.config = MonthConfig.determineConfig(from: entry.date)
    }

    var body: some View {
        VStack {
            HStack(spacing: 4) {
                Text(config.emojiText)
                    .font(.title)
                    .background(Color.black)
                    .compositingGroup()
                    .luminanceToAlpha()
                    .widgetAccentable()
                Text(entry.date.weekdayDisplayFormat)
                    .font(entry.showFunFont ? .custom(funFontName, size: 24) : .title3)
                    .fontWeight(.bold)
                    .minimumScaleFactor(0.6)
                    .foregroundStyle(showsBackground ? config.weekdayTextColor : .white)
                Spacer()
            }
            .id(entry.date)
            .transition(.push(from: .trailing))
            .animation(.spring, value: entry.date)

            Text(entry.date.dayDisplayFormat)
                .font(entry.showFunFont ? .custom(funFontName, size: 80) : .system(size: 80, weight: .heavy))
                .foregroundStyle(showsBackground ? config.dayTextColor : .white)
                .contentTransition(.numericText())
                .widgetAccentable()
        }
        .containerBackground(for: .widget) {
            ContainerRelativeShape()
                .fill(config.backgroundColor.gradient)
        }
    }
}

struct MonthlyWidget: Widget {
    let kind: String = "MonthlyWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ChangeFontIntent.self, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                MonthlyWidgetEntryView(entry: entry)
            } else {
                MonthlyWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Monthly Style Widget")
        .description("The theme of the widget changes based on month.")
        .supportedFamilies([.systemSmall])
    }
}

struct ChangeFontIntent: AppIntent, WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Fun font switch"
    static var description: IntentDescription = .init(stringLiteral: "Swift to a fun font")

    @Parameter(title: "Fun Font")
    var funFont: Bool?
}

#Preview(as: .systemSmall) {
    MonthlyWidget()
} timeline: {
    DayEntry(day: 1, month: 1)
    DayEntry(day: 12, month: 3)
    DayEntry(day: 22, month: 9)
    DayEntry(day: 30, month: 5, showFunFont: true)
    DayEntry(day: 17, month: 2)
    DayEntry(day: 25, month: 10)
}

extension Date {
    var weekdayDisplayFormat: String {
        self.formatted(.dateTime.weekday(.wide))
    }

    var dayDisplayFormat: String {
        self.formatted(.dateTime.day())
    }
}

extension WidgetConfiguration {
    func contentMarginsDisabledIfAvailable() -> some WidgetConfiguration {
        if #available(iOSApplicationExtension 17.0, *) {
            return self.contentMarginsDisabled()
        } else {
            return self
        }
    }
}
