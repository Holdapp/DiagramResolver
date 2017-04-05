//
//  UserInfoFlow.swift
//  DiagramResolver
//
//  Created by Lukasz Szyszkowski on 20.03.2017.
//  Copyright © 2017 Lukasz Szyszkowski. All rights reserved.
//

import PromiseKit

enum ViewType {
    case regular
    case premium
    case premiumRenew
}

enum AccountType {
    case regular
    case premium
}

struct UserInfo {
    let firstName = "John"
    let lastName = "Appleseed"
    let email = "user@holdapp.pl"
    let accountType = AccountType.premium
}

struct FlowHelper {
    let sessionExpired = false
    let sessionToken = "sadsdaf7a9s6gasfg9asfg6ds9fg6dfgsdfg"
    let premiumExpired = false
    let userInfo = UserInfo()
    let queue = DispatchQueue(label: "pl.holdapp.myqueue")
}

class UserInfoFlow {
    fileprivate let helper = FlowHelper()
    fileprivate var userInfo:UserInfo?
    fileprivate var finishedClosure:((ViewType)->())?
    
    func start(closure:@escaping (ViewType)->()) {
        finishedClosure = closure
        debugPrint("Start")
        firstly {
            return self.sessionValid()
            }.then { sessionExpired -> Promise<UserInfo> in
                debugPrint("- Is session expired: \(sessionExpired)")
                if sessionExpired {
                    return self.refreshToken()
                } else {
                    return self.getUserInfo()
                }
            }.then { userInfo -> Promise<Void> in
                debugPrint("- User info downloaded: \(userInfo.email)")
                self.userInfo = userInfo
                return self.checkAccountType()
            }.always {
                debugPrint("Promises chain finished - hide activity indicator etc.")
            }.catch { error in
                debugPrint(error)
        }
    }
}

// MARK: - promises

extension UserInfoFlow {
    // -- 1
    //
    fileprivate func sessionValid() -> Promise<Bool> {
        return Promise{fulfill, reject in
            fulfill(helper.sessionExpired)
        }
    }
    
    // -- 2
    //
    fileprivate func refreshToken() -> Promise<UserInfo> {
        return firstly {
            Promise<String>(value: self.helper.sessionToken)
            }.then { token -> Promise<UserInfo> in
                debugPrint("- Token refreshed: \(token)")
                return self.getUserInfo()
        }
    }
    
    // -- 3
    //
    fileprivate func getUserInfo() -> Promise<UserInfo> {
        return Promise{fulfill, reject in
            self.helper.queue.async {
                for _ in 0...1000000000 {}
                DispatchQueue.main.sync {
                    fulfill(self.helper.userInfo)
                }
            }
        }
    }
    
    // -- 4
    //
    fileprivate func checkAccountType() -> Promise<Void> {
        if let userInfo = userInfo {
            debugPrint("- Account type checked: \(userInfo.accountType)")
            switch userInfo.accountType {
            case .premium:
                return self.premiumAccountFlow()
            case .regular:
                return self.regularAccountFlow()
            }
        } else {
            return Promise{fulfill, reject in reject(NSError.cancelledError())}
        }
    }
    
    // -- 4.1
    //
    fileprivate func premiumAccountFlow() -> Promise<Void>  {
        return firstly {
            self.isPremiumPlanExpired()
            }.then { expired -> Promise<Void> in
                if expired {
                    return self.renewPremiumAccount()
                } else {
                    return self.premiumUserAccount()
                }
        }
    }
    
    // -- A
    //
    fileprivate func regularAccountFlow() -> Promise<Void> {
        return Promise {fulfill, reject in
            if let closure = finishedClosure {
                closure(.regular)
            }
            fulfill()
        }
    }
    
    // -- B
    //
    fileprivate func premiumUserAccount() -> Promise<Void> {
        return Promise {fulfill, reject in
            if let closure = finishedClosure {
                closure(.premium)
            }
            fulfill()
        }
    }
    
    // -- C
    //
    fileprivate func renewPremiumAccount() -> Promise <Void> {
        return Promise {fulfill, reject in
            if let closure = finishedClosure {
                closure(.premiumRenew)
            }
            fulfill()
        }
    }
    
    // -- 5
    //
    fileprivate func isPremiumPlanExpired() -> Promise<Bool> {
        return Promise{fulfill, reject in
            fulfill(self.helper.premiumExpired)
        }
    }
    
}
