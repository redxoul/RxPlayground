import UIKit
import RxSwift
import RxCocoa

// share(replay:scope:)
// subscribe할 때 기존에 만들어진 시퀀스가 있다면,
// 새로 생성되지 않고 처음 subscribe했을 때 방출된 Element를 공유해서 사용할 수 있게 됩니다.
let response = Observable.from(["ReactiveX/RxSwift"])
  .map { urlString -> URL in
    // URL로 mapping해서 방출하겠다고 명시
    return URL(string: "https://api.github.com/repos/\(urlString)/events")!
  }
  .map { url -> URLRequest in
    // 위에서 URL을 받아서 URLRequest로 다시 mapping
    var request = URLRequest(url: url)
    return request
  }
  .flatMap { request -> Observable<(response: HTTPURLResponse, data: Data)> in
    // RxCocoa의 rx.response : 웹서버로부터 전체 응답을 받을 때마다 완료되는 Observable<(response: HTTPURLResponse, data: Data)>을 반환
    // delegate없이 바로 응답을 받을 수 있음.
    return URLSession.shared.rx.response(request: request)
  }
  .share(replay: 1)

response
    .subscribe(onNext: {
        print($0.data)
    })

response
    .subscribe(onNext: {
        print($0.data)
    })
