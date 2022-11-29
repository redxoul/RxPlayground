import RxSwift

// just
// 단 하나의 Next이벤트로 Element를 방출하고 종료하는 Observable 시퀀스를 생성합니다.
print("----- just(1) -----")
Observable<Int>.just(1)
    .subscribe(onNext: {
        print($0)
    })

// of
// 여러개의 이벤트를 방출시키는 Observable을 생성합니다.
print("----- of (1) -----")
Observable<Int>.of(1, 2, 3, 4, 5)
    .subscribe(onNext: {
        print($0)
    })

print("----- of (2) -----")
Observable.of([1, 2, 3, 4, 5])
    .subscribe(onNext: {
        print($0)
    })

// just 연산자로 하나의 Array를 방출하는 것과 동일합니다.
print("----- just(2) -----")
Observable.just([1, 2, 3, 4, 5])
    .subscribe(onNext: {
        print($0)
    })

// from
// From은 배열([Element])로 입력을 받아서,
// 배열 내 값을 하나씩 방출시키는 Observable<Element>시퀀스을 생성합니다.
print("----- from -----")
Observable.from([1, 2, 3, 4, 5])
    .subscribe(onNext: {
        print($0)
    })
// of와 달리 Array를 넣었을 때 알아서 Array의 Element들을 방출합니다.
 
// Observable은 시퀀스에 대한 정의일 뿐 subscribe하기 전엔 아무것도 방출하지 않습니다.

print("----- subscribe (1) -----")
Observable.of(1, 2, 3)
    .subscribe {
        print($0)
    }

print("----- subscribe (2) -----")
Observable.of(1, 2, 3)
    .subscribe {
        if let element = $0.element {
            print(element)
        }
    }

print("----- subscribe (3) -----")
Observable.of(1, 2, 3)
    .subscribe(onNext: {
        print($0)
    })

// empty
// 값이 빈 Observable을 생성합니다. Completed이벤트만 방출합니다.
// empty일 때는 아무값도 넣지 않아 타입추론을 할 수 없어서
// Observable에 <Void>를 명시해주어야만 Completed 이벤트를 발생시킵니다.
// 의도적으로 값이 없는, 즉시 종료하는 Observable을 반환해야할 때 유용합니다.
print("----- empty -----")
Observable<Void>.empty()
    .subscribe {
        print($0)
    }

// never
// 방출되는 값도 없고, 종료이벤트(completed, error)도 발생하지 않는 무한의 Observable을 생성합니다.
print("----- never -----")
Observable.never()
    .debug("never")
    .subscribe(onNext: {
        print($0) // subscribe는 되지만, 아무것도 방출하지 않습니다.
    }, onCompleted: {
        print("completed")
    })

// range
// 특정범위의 값이 순차적으로 증가하는 Observable을 생성시킵니다.
// start값, count값 외에 옵셔널로 scheduler를 지정해줄 수 있습니다.
print("----- range -----")
Observable.range(start: 1, count: 9)
    .subscribe(onNext: {
        print("2 * \($0) = \(2*$0)")
    })

print("----- dispose -----")
Observable.of(1, 2, 3)
    .subscribe {
        print($0)
    }
    .dispose()
// 유한한 element가 다 방출되면 dispose하지 않아도 completed됩니다.
// 무한한 element를 방출하는 Observable이라면 dispose를 시켜주어야만 completed 시킬 수 있습니다.

// disposeBag
// Observable을 사용하는 흔한 패턴입니다.
// dispose를 해주지 않으면 memory leak이 발생할 수 있습니다.
print("----- disposeBag -----")
let disposeBag = DisposeBag()

Observable.of(1, 2, 3)
    .subscribe {
        print($0)
    }
    .disposed(by: disposeBag)

// create
// 각 이벤트들을 방출시키는 onNext, onCompleted, onError 를 직접 구현하는 방식입니다.
print("----- create (1) -----")
Observable.create { observer -> Disposable in
    observer.onNext(1)
//    observer.on(.next(1))
    observer.onCompleted()
//    observer.on(.completed)
    observer.onNext(2) // completed 이벤트 후에는 Observable 이벤트가 종료되어 실행되지 않습니다.
    return Disposables.create()
}
.subscribe {
    print($0)
}
.disposed(by: disposeBag)

print("----- create (2) -----")
enum MyError: Error {
    case anError
}

Observable<Int>.create { observer -> Disposable in
    observer.onNext(1)
    observer.onError(MyError.anError)
    observer.onNext(2)
    return Disposables.create()
}
.subscribe(onNext: {
    print($0)
}, onError: {
    print($0.localizedDescription)
}, onCompleted: {
    print("completed")
}, onDisposed: {
    print("disposed")
})
.disposed(by: disposeBag)

// deferd
// subscriber를 기다리는 Observable을 만드는 대신
// subscriber에게 새로운 Observable항목을 제공하는 Factory를 만듭니다.
print("----- deferred (1) -----")
Observable.deferred {
    Observable.of(1, 2, 3)
}
.subscribe {
    print($0)
}
.disposed(by: disposeBag)

print("----- deferred (2) -----")
var 뒤집기: Bool = false
let factory: Observable<String> = Observable.deferred {
    뒤집기 = !뒤집기

    if 뒤집기 {
        return Observable.of("👍🏻")
    }
    else {
        return Observable.of("👎🏻")
    }
}

for _ in 0...3 {
    factory.subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)
}

print("----- deffered (3) -----")
// 반환할 observable을 flip할 플래그
var flip = false
// defer를 사용. Int형 Observable을 반환하는 factory 생성
let factory2: Observable<Int> = Observable.deferred {
    // subscribe될 때마다 flip의 toggle이 발생
    flip.toggle()
            
    // flip에 따라 다른 observable을 반환
    if flip {
        return Observable.of(1, 2, 3)
    } else {
        return Observable.of(4, 5, 6)
    }
}

// subscribe
for _ in 0...3 {
    factory2.subscribe(onNext: {
        print($0, terminator: " ")
    })
    .disposed(by: disposeBag)

    print()
}
