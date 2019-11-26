//
//  SettingsSection.swift
//  SettingsTemplate
//
//  Created by Stephen Dowless on 2/10/19.
//  Copyright © 2019 Stephan Dowless. All rights reserved.
//

protocol SectionType: CustomStringConvertible {
    var containsSwitch: Bool { get }
}

enum SettingsSection: Int, CaseIterable, CustomStringConvertible {
    case Social
    
    var description: String {
        switch self {
        case .Social: return "Social"
        }
    }
}

enum SocialOptions: Int, CaseIterable, SectionType {
    case loginAttempts
    
    var containsSwitch: Bool { return false }
    
    var description: String {
        switch self {
        case .loginAttempts: return "View Login Attempts"
        }
    }
}
