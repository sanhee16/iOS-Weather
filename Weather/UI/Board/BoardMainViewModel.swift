//
//  BoardMainViewModel.swift
//  Weather
//
//  Created by sandy on 2022/10/10.
//

import Foundation
import Combine
import UIKit
import FirebaseCore
import FirebaseFirestore
import SwiftUI

class BoardMainViewModel: BaseViewModel {
    private let savedList: [WeatherType] = [.clearSky, .fewClouds, .scatteredClouds, .brokenClouds, .showerRain, .rain, .thunderStorm, .snow, .mist]
    @Published var weatherList: [WeatherType] = []
    private var currentWeatherType: WeatherType
    @Published var allData: [Board] = []
    @Published var selectedIdx: Int
    @Published var isLoading: Bool = true
    private var db: Firestore
    private var idx: Int = 0
    
    init(_ coordinator: AppCoordinator, weatherType: WeatherType) {
        self.currentWeatherType = weatherType
        self.selectedIdx = 0
        self.db = Firestore.firestore()
        super.init(coordinator)
        
        // make top menu
        self.weatherList.append(self.currentWeatherType)
        for i in savedList {
            if i == self.currentWeatherType { continue }
            self.weatherList.append(i)
        }
    }
    
    func onAppear() {
//        self.isLoading = false
        loadAllData()
    }
    
    func onClose() {
        self.dismiss()
    }
    
    func onChangeWeatherMenu(_ idx: Int) {
        withAnimation {
            self.selectedIdx = idx
        }
    }
    
    func loadAllData() {
        self.isLoading = true
        self.allData.removeAll()
        db.collection("list").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                self.isLoading = false
            } else {
                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(document.data())")
                    let data = document.data()
                    if let type = data["type"] as? Int,
                       let text = data["text"] as? String,
                       let createdAt = data["createdAt"] as? Int {
                        self.allData.append(Board(type: type, text: text, createdAt: createdAt))
                    }
                }
                self.allData.sort { (lhs, rhs) in return lhs.createdAt > rhs.createdAt }
                self.isLoading = false
            }
        }
    }
    
    func onClickAddButton() {
        self.coordinator?.presentSelectWeatherView() {[weak self] type in
            self?.coordinator?.presentWriteBoardView(type: type)
        }
    }
    
}
