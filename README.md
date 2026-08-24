# MachineCodingStarter

SwiftUI starter for a 90-minute iOS round. Core is POP + DI. You type View + ViewModel.

```text
View → ViewModel → ProductRepository → APIClient + DataDecoding + Cache
                         ↓
                      DTO → Domain
AppContainer wires the protocols.
```

Open `MachineCodingStarter.xcodeproj` and run **MachineCodingStarter**.

| Layer | Protocol | Impl |
| --- | --- | --- |
| API | `APIClient` | `URLSessionAPIClient` (Data only) |
| Decoding | `DataDecoding` | `JSONDataDecoder` + `ProductDTO.toDomain()` |
| Cache | `Caching` | `MemoryCache` |
| Repo | `ProductRepository` | `DefaultProductRepository` |
| DI | — | `AppContainer` |

Keep `ProductListView` / `ProductListViewModel`. Swap DTO + repository method when the problem changes.

```bash
cd MachineCodingStarter
xcodegen generate
xcodebuild test -scheme MachineCodingStarter -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```
