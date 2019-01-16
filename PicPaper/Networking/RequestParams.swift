//
//  RequestParams.swift
//  PicPaper
//
//  Created by Arlindo on 8/18/18.
//  Copyright © 2018 DevByArlindo. All rights reserved.
//

import Foundation

typealias Params = [String: Any]

struct RequestParams {

    private struct Contants {
        static let pixbayApiKey: String = "9859816-72e4c0ab32f0af6365acfc6ce"
        static let minimumPageNumber: Int = 1
        static let minimumRequestCount: Int = 3
    }

    private struct ParamKeys {
        static let key: String = "key"
        static let order: String = "order"
        static let page: String = "page"
        static let resultCount: String = "per_page"
        static let searchTerm: String = "q"
        static let safeSearch: String = "safesearch"
    }

    enum ParamValues {

        enum Order: String {
            case popular
            case latest
        }

        case order(Order)
        case page(Int)
        case safeSearch(Bool)
        case searchTerm([String])
        case resultCount(Int)

        var key: String {
            switch self {
            case .order:
                return ParamKeys.order
            case .page:
                return ParamKeys.page
            case .safeSearch:
                return ParamKeys.safeSearch
            case .searchTerm:
                return ParamKeys.searchTerm
            case .resultCount:
                return ParamKeys.resultCount
            }
        }

        var value: Any {
            switch self {
            case .order(let order):
                return order.rawValue
            case .page(let pageNumber):
                return max(Contants.minimumPageNumber, pageNumber)
            case .safeSearch(let isSafe):
                return "\(isSafe)"
            case .searchTerm(let searchTerms):
                return searchTerms.joined(separator: "+")
            case .resultCount(let count):
                return max(Contants.minimumRequestCount, count)
            }
        }
    }

    static func buildParams(values: [ParamValues]) -> Params {
        let initalParam = [ParamKeys.key: Contants.pixbayApiKey]
        return values.reduce(initalParam, { (currentParams, nextParam) -> Params in
            return currentParams.merging([nextParam.key: nextParam.value], uniquingKeysWith: { _, key2 in key2 })
        })
    }
}
