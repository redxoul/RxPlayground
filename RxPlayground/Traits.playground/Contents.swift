import RxSwift

// Traits: Single, Maybe, Completable
// 좀 더 좁은 범위의 Observable
// 코드 가독성을 위해 사용됩니다.

let disposeBag = DisposeBag()

enum TraitsError: Error {
    case single
    case maybe
    case completable
}

// Single
// : .Success(next+complete), .failure 를 한번만 방출하는 Observable 입니다.
// 파일 저장, 다운로드, 디스크데이터 리딩과 같이 한가지 결과를 내놓고 끝내는 비동기적 동작에 주로 사용됩니다.
print("- - - - - Single (1) - - - - -")
Single<String>.just("✅")
    .subscribe(
        onSuccess: {
            print($0)
        }, onFailure: {
            print("error: \($0)")
        }, onDisposed: {
            print("disposed")
        }
    )
    .disposed(by: disposeBag)

// asSingle
// Observable을 single로 변환시켜줍니다.
// Observable을 asSingle을 통해 Single로 전환했을 때 몇 가지 문제가 발생할 수 있습니다.
// (1) next이벤트 이후에 completed이벤트가 발생하지 않으면 observer가 success이벤트를 받을 수가 없습니다.
// (2) 그리고 next이벤트가 발생하기 전에 completed이벤트가 먼저 발생하면 방출하기로 한 데이터가 없기 때문에 observer는 error이벤트를 받게 됩니다.
print("- - - - - Single (2) - - - - -")
//Observable<String>.just("✅")
Observable<String>
    .create { observer -> Disposable in
        observer.onNext("asSingle")
        observer.onCompleted()
//        observer.onError(TraitsError.single)
        return Disposables.create()
    }
    .asSingle() // single로 변환시켜줍니다.
    .subscribe(
        onSuccess: {
            print($0)
        }, onFailure: {
            print("error: \($0)")
        }, onDisposed: {
            print("disposed")
        }
    )
    .disposed(by: disposeBag)


print("- - - - - Single (3) - - - - -")
struct SomeJSON: Decodable {
    let name: String
}

enum JSONError: Error {
    case decodingError
}

let json1 = """
        {"name":"park"}
    """

let json2 = """
        {"my name":"cody"}
    """

func decode(json: String) -> Single<SomeJSON> {
    Single<SomeJSON>.create { observer -> Disposable in
        guard let data = json.data(using: .utf8),
              let json = try? JSONDecoder().decode(SomeJSON.self, from: data) else {
            observer(.failure(JSONError.decodingError))
            return Disposables.create()
        }
        
        observer(.success(json))
        return Disposables.create()
    }
}

decode(json: json1)
    .subscribe {
        switch $0 {
        case .success(let json):
            print(json.name)
        case .failure(let error):
            print("error: \(error)")
        }
    }
    .disposed(by: disposeBag)

// Completable
// : .completed, .error 만 방출하는 Observable 입니다.
// 동기식 연산의 성공여부를 확인할 때 유용하게 사용됩니다.
// (예시) 유저가 어떤 작업을 할 동안 자동으로 저장하는 기능을 만들고 싶을 때. 백그라운드 저장작업을 한 후 완료가 되거나 오류가 났을 때 noti를 띄우는 작업
// (Single, Maybe처럼 Observable에서 전환해주는 것은 없음)
print("- - - - - Completable (1) - - - - -")
Completable.create { observer -> Disposable in
    observer(.error(TraitsError.completable))
    return Disposables.create()
}
.subscribe(
    onCompleted: {
        print("completed")
    },
    onError: {
        print("error: \($0)")
    },
    onDisposed: {
        print("disposed")
    }
)
.disposed(by: disposeBag)

print("- - - - - Completable (2) - - - - -")
Completable.create { observer -> Disposable in
    observer(.completed)
    return Disposables.create()
}
.subscribe {
    print($0)
}
.disposed(by: disposeBag)


//func saveText(fileName: String, text: String) -> Completable {
//    // Completable을 만들어 반환
//    return Completable.create { observer -> Disposable in
//        // Observable과 같이 Disposable을 반환해야 하므로
//        // 반환할 Disposable을 생성
//        let disposable = Disposables.create()
//
//        let fileManager = FileManager.default
//
//        let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
//
//        guard let directoryURL = documentURL?.appendingPathComponent("FolderName") else {
//            observer(.error(TraitsError.completable))
//            return disposable
//        }
//
//        do {
//            try fileManager.createDirectory(atPath: directoryURL.path, withIntermediateDirectories: false)
//        } catch let error {
//            observer(.error(error))
//            return disposable
//        }
//
//        let filePath = directoryURL.appendingPathComponent(fileName)
//
//        do {
//            try text.write(to: filePath, atomically: false, encoding: .utf8)
//        } catch let error {
//            observer(.error(error))
//            return disposable
//        }
//
//        observer(.completed)
//        return disposable
//    }
//}
//
//saveText(fileName: "someFile", text: "someText")
//    .subscribe (
//        onCompleted: {
//            print("completed")
//        },
//        onError: {
//            print("error: \($0)")
//        }
//    )
//    .disposed(by: disposeBag)


// Maybe
// : .Success, .completed, .error를 방출하는 Observable
// Single과 Completable을 합쳐놓은 개념입니다.
// Single과 비슷하지만 아무값도 없이 끝낼 수 있습니다(completed)
print("- - - - - Maybe (1) - - - - -")
Maybe<String>.just("Maybe")
.subscribe(
    onSuccess: {
        print($0)
    },
    onError: {
        print("error: \($0)")
    },
    onCompleted: {
        print("completed")
    },
    onDisposed: {
        print("disposed")
    }
)
.disposed(by: disposeBag)

// asMaybe
// 어떤 Observable을 Maybe로 바꾸고 싶다면 -> asMaybe로 바꿔줄 수 있음
// asSingle와 비슷한 문제를 가지고 있습니다.
// Observable에서 next이벤트를 방출했어도 completed이벤트를 방출하기 전까지 asMaybe의 success(value)이벤트를 받을 수가 없습니다.
print("- - - - - Maybe (2) - - - - -")
Observable<String>.create { observer -> Disposable in
//        observer.onError(TraitsError.maybe)
observer.onNext("asMaybe")
observer.onCompleted()
    return Disposables.create()
}
.asMaybe()
.subscribe(
    onSuccess: {
        print($0)
    },
    onError: {
        print("error: \($0)")
    },
    onCompleted: {
        print("completed")
    },
    onDisposed: {
        print("disposed")
    }
)
.disposed(by: disposeBag)
