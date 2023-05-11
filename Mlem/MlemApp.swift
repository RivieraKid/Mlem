//
//  MlemApp.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import SwiftUI
import SwiftyJSON

@main
struct MlemApp: App
{
    @StateObject var appState: AppState = .init()
    @StateObject var accountsTracker: SavedAccountTracker = .init()
    @StateObject var filtersTracker: FiltersTracker = .init()

    @StateObject var selectedImageTracker: SelectedImageTracker = .init()
    
    var body: some Scene
    {
        WindowGroup
        {
            ContentView()
                .environmentObject(appState)
                .environmentObject(accountsTracker)
                .environmentObject(filtersTracker)
                .environmentObject(selectedImageTracker)
                .onChange(of: accountsTracker.savedAccounts)
                { newValue in
                    do
                    {
                        let encodedSavedAccounts: Data = try encodeForSaving(object: newValue)

                        do
                        {
                            try writeDataToFile(data: encodedSavedAccounts, fileURL: AppConstants.savedAccountsFilePath)
                        }
                        catch let writingError
                        {
                            print("Failed while saving data to file: \(writingError)")
                        }
                    }
                    catch let encodingError
                    {
                        print("Failed while encoding accounts to data: \(encodingError)")
                    }
                }
                .onChange(of: filtersTracker.filteredKeywords)
                { newValue in
                    print("Change detected in filtered keywords: \(newValue)")
                    do
                    {
                        let encodedFilteredKeywords: Data = try encodeForSaving(object: newValue)

                        print(encodedFilteredKeywords)
                        do
                        {
                            try writeDataToFile(data: encodedFilteredKeywords, fileURL: AppConstants.filteredKeywordsFilePath)
                        }
                        catch let writingError
                        {
                            print("Failed while saving data to file: \(writingError)")
                        }
                    }
                    catch let encodingError
                    {
                        print("Failed while encoding filters to data: \(encodingError)")
                    }
                }
                .onAppear
                {
                    if FileManager.default.fileExists(atPath: AppConstants.savedAccountsFilePath.path)
                    {
                        print("Saved Accounts file exists, will attempt to load saved accounts")

                        do
                        {
                            accountsTracker.savedAccounts = try decodeFromFile(fromURL: AppConstants.savedAccountsFilePath, whatToDecode: .accounts) as! [SavedAccount]
                        }
                        catch let savedAccountDecodingError
                        {
                            print("Failed while decoding saved accounts: \(savedAccountDecodingError)")
                        }
                    }
                    else
                    {
                        print("Saved Accounts file does not exist, will try to create it")

                        do
                        {
                            try createEmptyFile(at: AppConstants.savedAccountsFilePath)
                        }
                        catch let emptyFileCreationError
                        {
                            print("Failed while creating an empty file: \(emptyFileCreationError)")
                        }
                    }

                    if FileManager.default.fileExists(atPath: AppConstants.filteredKeywordsFilePath.path)
                    {
                        print("Filtered keywords file exists, will attempt to load blocked keywords")
                        do
                        {
                            filtersTracker.filteredKeywords = try decodeFromFile(fromURL: AppConstants.filteredKeywordsFilePath, whatToDecode: .filteredKeywords) as! [String]
                        }
                        catch let savedKeywordsDecodingError
                        {
                            print("Failed while decoding saved filtered keywords: \(savedKeywordsDecodingError)")
                        }
                    }
                    else
                    {
                        print("Filtered keywords file does not exist, will try to create it")

                        do
                        {
                            try createEmptyFile(at: AppConstants.filteredKeywordsFilePath)
                        }
                        catch let emptyFileCreationError
                        {
                            print("Failed while creating an empty file: \(emptyFileCreationError)")
                        }
                    }
                }
        }
    }
}
