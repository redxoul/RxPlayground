import RxSwift

let disposeBag = DisposeBag()

// ignoreElements
// 모든 next이벤트를 무시합니다. error, complete로 종료되는 이벤트만 받습니다.
print("- - - - - ignoreElements - - - - -")
let takeAlmond = PublishSubject<String>()

takeAlmond
    .ignoreElements()
    .subscribe {
        print("take Honey butter Almond")
    }
    .disposed(by: disposeBag)

takeAlmond.onNext("MintChoco Almond is here")
takeAlmond.onNext("MintChoco Almond is here")
takeAlmond.onNext("MintChoco Almond is here")

takeAlmond.onCompleted()

// elementAt
// subscribe한 후 n번째 인덱스의 Element만 받습니다.
print("- - - - - elementAt - - - - -")

let reTakeAlmond = PublishSubject<String>()

reTakeAlmond
    .element(at: 2)
    .subscribe(onNext: {
        print("eat", $0, "Almond")
    })

reTakeAlmond.onNext("MintChoco")
reTakeAlmond.onNext("MintChoco")
reTakeAlmond.onNext("Wasabi")
reTakeAlmond.onNext("MintChoco")


// filter
// Swift Collection 타입에서 제공하는 filter와 동일한 기능의 Operator입니다.
// filter클로저에서 true인 케이스의 next이벤트를 받도록 합니다.
print("- - - - - filter - - - - -")
Observable.of("MintChoco", "Wasabi", "MintChoco", "HoneyButter", "MintChoco", "Buldak")
    .filter { $0 != "MintChoco" }
    .subscribe(onNext: {
        print("Eat", $0, "Almond")
    })
    .disposed(by: disposeBag)

// skip
// n개만큼 next를 skip하고나서 next이벤트를 받습니다.
print("- - - - - skip - - - - -")
Observable.of("MintChoco", "MintChoco", "MintChoco", "HoneyButter", "Wasabi", "Corn")
    .skip(3)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

// skipWhile
// while클로저가 true인 동안 skip을 시키고, false가 된 순간부터 next이벤트를 받습니다.
print("- - - - - skipWhile - - - - -")
Observable.of("MintChoco", "MintChoco", "MintChoco", "HoneyButter", "Wasabi", "Corn")
    .skip(while: {
        $0 == "MintChoco"
    })
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

// skipUntil
// skipUntil은 다른 Observable을 트리거로 설정해서,
// 트리거로 설정한 Observable이 값을 방출할 때까지 skip을 시킵니다.
print("- - - - - skipUntil - - - - -")

let buyAlmond = PublishSubject<String>()
let soldoutMintChoco = PublishSubject<String>()

buyAlmond.skip(until: soldoutMintChoco)
    .subscribe(onNext: {
        print("buy", $0)
    })
    .disposed(by: disposeBag)

buyAlmond.onNext("MintChoco")
buyAlmond.onNext("MintChoco")

soldoutMintChoco.onNext("soldout MintChoco")

buyAlmond.onNext("Wasabi")
buyAlmond.onNext("Corn")
buyAlmond.onNext("Buldak")

// take
// take는 n개의 Element만 받도록 합니다.
print("- - - - - take - - - - -")
Observable.of("Buldak", "Wasabi", "HoneyButter", "MintChoco", "MintChoco", "MintChoco")
    .take(3)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

// takeWhile
// takeWhile은 while클로저가 true인 동안만 Element를 받습니다.
print("- - - - - takeWhile - - - - -")
Observable.of("Buldak", "Wasabi", "HoneyButter", "MintChoco", "MintChoco", "MintChoco")
    .take(while: {
        $0 != "MintChoco"
    })
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

// enumerated
// 방출되는 element 순서대로 index를 함께 튜플로 보내줍니다.
print("- - - - - enumerated - - - - -")
Observable.of("🥇", "🥈", "🥉", "😎", "🤩")
    .enumerated()
    .take(while: {
        $0.index < 3
    })
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

// takeUntil
// 다른 Observable을 트리거로 설정하여, 트리거로 설정한 Observable이 값을 방출할 때까지만 값을 받습니다.
print("- - - - - takeUntil - - - - -")
let eatAlmond = PublishSubject<String>()
let giveMintChoco = PublishSubject<String>()

eatAlmond
    .take(until: giveMintChoco)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

eatAlmond.onNext("Wasabi")
eatAlmond.onNext("HoneyButter")

giveMintChoco.onNext("MintChoco가 왔어요")

eatAlmond.onNext("Buldak")

// distinctUntilChanged
// 기존에 받은 Element와 다른 Element가 들어왔을 때만 값을 받게 해주어
// 중복된 값을 받지 않도록 막아줍니다.
print("- - - - - distinctUntilChanged - - - - -")
Observable.of("Buldak", "Wasabi", "Wasabi", "HoneyButter", "MintChoco", "MintChoco", "MintChoco", "Wasabi")
    .distinctUntilChanged()
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

