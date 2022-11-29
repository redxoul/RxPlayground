import RxSwift

let disposeBag = DisposeBag()

// toArray
// Observable의 모든 Element들을 하나의 Array로 묶인 Single로 변환시켜줍니다.
print("- - - - - toArray - - - - -")
Observable.of("HoneyButter", "Wasabi", "Buldak", "MintChoco")
    .toArray()
    .subscribe(onSuccess: {
        print($0)
    })
    .disposed(by: disposeBag)


// map
// Swift에서 제공하는 map과 동일한 기능의 Operator입니다.
print("- - - - - map - - - - -")
Observable.of(Date())
    .map { date -> String in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        return dateFormatter.string(from: date)
    }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)


// flatmap
// Observable 내부의 Observable(inner Observable)을 다루기 위한 Operator입니다.
// 중첩된 Observable 내부의 Observable을 꺼내서 쓸 수 있습니다.
print("- - - - - flatmap - - - - -")

protocol Almond {
    var tasteScore: BehaviorSubject<Int> { get }
}

struct Taster: Almond {
    var tasteScore: BehaviorSubject<Int>
}

let wasabiTaster = Taster(tasteScore: BehaviorSubject<Int>(value: 10))
let mintChocoTaster = Taster(tasteScore: BehaviorSubject<Int>(value: 1))

let tasting = PublishSubject<Taster>()

tasting
    .flatMap { Taster in
        Taster.tasteScore
    }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

tasting.onNext(wasabiTaster)
wasabiTaster.tasteScore.onNext(10)

tasting.onNext(mintChocoTaster)
wasabiTaster.tasteScore.onNext(10)
wasabiTaster.tasteScore.onNext(10)
mintChocoTaster.tasteScore.onNext(1)


// flatmapLatest
// flatMap과 유사하지만, 상위 Observable에서 마지막으로 next된 내부 Observable의 값만 subscribe하게 됩니다.
// map과 switchLatest의 조합.
print("- - - - - flatmapLatest - - - - -")
let buldakTaster = Taster(tasteScore: BehaviorSubject<Int>(value: 9))
let cornTaster = Taster(tasteScore: BehaviorSubject<Int>(value: 8))


let tasting2 = PublishSubject<Taster>()

tasting2
    .flatMapLatest { Taster in
        Taster.tasteScore
    }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

tasting2.onNext(buldakTaster)
buldakTaster.tasteScore.onNext(9)

tasting2.onNext(cornTaster)
buldakTaster.tasteScore.onNext(9)
cornTaster.tasteScore.onNext(8)

tasting2.onNext(buldakTaster)
cornTaster.tasteScore.onNext(8)


// materialize
// 내부의 Observable의 값만이 아닌, 이벤트 및 이벤트값을 함께 받을 수 있게 변환시켜줍니다.
// 보통은 Observable속성의 Observable을 제어할 수 없습니다.
// 내부 Observable의 error로 인해 외부의 Observable이 종료되는 걸 방지하고자 Error이벤트를 처리하고 싶을 때 사용됩니다.

// dematerialize
// : 이벤트 및 이벤트값을 받던 것을 다시 이벤트값만 받도록 변환해줍니다.
print("- - - - - materialize, dematerialize - - - - -")

enum hate: Error {
    case MintChoco
}

let me = Taster(tasteScore: BehaviorSubject<Int>(value: 10))
let you = Taster(tasteScore: BehaviorSubject<Int>(value: 8))

let almondEating = PublishSubject<Taster>()

almondEating
    .flatMapLatest { Taster in
        Taster.tasteScore
            .materialize()
    }
    .filter {
        guard let error = $0.error else { return true }
        print("Error: ", error) // error는 출력만 해주고 필터링
        return false
    }
    .dematerialize()
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

almondEating.onNext(me)
me.tasteScore.onNext(10)
me.tasteScore.onError(hate.MintChoco) // me Observable은 종료
almondEating.onNext(you) // 외부 Observable은 종료되지 않음
you.tasteScore.onNext(8)
you.tasteScore.onNext(8)


print("- - - - - 전화번호 11자리 예제 - - - - -")

let input = PublishSubject<Int?>()

let list: [Int] = [1]

input
    .flatMap {
        $0 == nil
        ? Observable.empty()
        : Observable.just($0)
    }
    .map { $0! } // 위에서 이미 nil일 때의 처리가 되었기 떄문에 강제 언래핑
    .skip(while: { $0 != 0 }) // 전화번호가 0부터 시작하기 때문에 0이 나올 떄까지 skip
    .take(11) // 11자리를 받음
    .toArray() // Single로 Array를 전달
    .asObservable() // 다시 Observable로 전달
    .map { $0.map { "\($0)" } } // String 타입으로 변환
    .map { numbers in
        var numberList = numbers
        numberList.insert("-", at: 3) // 010-
        numberList.insert("-", at: 8) // 010-1234-
        let number = numberList.reduce("", +)
        return number
    }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

input.onNext(10)
input.onNext(0)
input.onNext(nil)
input.onNext(1)
input.onNext(0)
input.onNext(1)
input.onNext(2)
input.onNext(3)
input.onNext(4)
input.onNext(5)
input.onNext(6)
input.onNext(7)
input.onNext(8)
