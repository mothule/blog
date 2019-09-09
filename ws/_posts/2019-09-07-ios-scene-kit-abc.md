---
title: 360度パノラマ画像を閲覧するpod更新でGLKitからSceneKitに変えた話
categories: ios scene-kit
tags: ios scene-kit swift
---
GLKitからSceneKitに変えざるを得ない状況に直面し、SceneKitの調査や躓いたポイントについてまとめます。

## きっかけ

先日国内最大のiOS開発者カンファレンス iOSDC Japan 2019に参加して、AVFoundationを使っているセッションばかり聞いていたら
「自分も何か発表できるネタないかな？発表してみたいな。」とウズウズした結果、過去の自作ライブラリで人気がある360度パノラマ画像ビューワーをSwift5に追従して動くようにして、実現方法などについてスライド纏めれば、ちょっとした登壇とかできそうだなと思ったことがきっかけです。

この自作ライブラリは以前[Qiita](https://qiita.com/mothule/items/026bac1cf1fc229d0c4d)に書いてあります

## Swift5に変えたが動かず

ライブラリのSwift言語はSwift3なので古いな〜と思いつつSwift5にして、ビルドが通ったので実行したのですが、画面が白いままで全く何も表示されませんでした。

原因がいまいち分からず、情報集めるため公式ドキュメントを覗いたら驚愕しました。

{% page_image -1.png 50% %}

**oh...** なんとほぼ全部が `Deprecated` ラベルがついてました。

これでは折角ライブラリのSwiftを追従させても、追従したとは言えません。
Swiftバージョンだけでなく、描画周りも一新することにしました。

## SceneKitってのが出てた

[公式サイト](https://developer.apple.com/documentation)を１つに戻って見てみたらSceneKitと呼ばれるフレームワークを見つけました。
googleで調べてもGLKitは影を潜めMetalやSceneKit,ARKitが並んでいます。

### SceneKitは3Dゲームやコンテンツの上位レイヤー開発キット

GLKitが低レイヤーだとすれば、SceneKitは上位レイヤーに当たります。
GLKitが描画エンジンだとすれば、SceneKitはゲームエンジンといったところでしょうか。
また描画だけでなくアニメーション,物理演算などもサポートしています。

SceneKitは描画テクノロジーにはGLKitやMetalが使われています。
OpenGLかDirectXかなど描画エンジンになるべく気にせずコンテンツ作りに特化しやすい開発キットってことですね。
それゆえ、GLKitを直接使われるよりは新しく提供したSceneKitを使うようGLKitを非推奨にしたのかもしれません。

GLKitと異なりSceneKitではOpenGLを直接操作するのではなく、Sceneと呼ばれる単位で描画環境の構築を行います。  
そしてこのScene内はNodeと呼ばれるディレクトリのような階層構造で描画オブジェクトを管理しています。

{% page_image -2.png %}
↑ [公式](https://developer.apple.com/documentation/scenekit/scnscene)より抜粋

映画の1シーンと捉えると理解がしやすいかと思います。

- ロケ地で撮影 : landscapeNode
- 俳優が立つ : characterNode
- カメラで撮影 : cameraNode
- 照明で照らす : lightNode

### SCNNodeはデザインとしては多少強引な何でもボックス

このNodeと呼ばれるものは`SCNNode`一つで上の全てのオブジェクトをサポートしている
設計としては多少強引な何でもボックスです。

なぜなら

- ライト
- カメラ
- アニメーション

へのアクセスプロパティを持っており、設定によってどれにでもなり得るからです。
ただこのような設計にしたのは、Nodeによる階層構造をシンプルにしたかったかもしれません。

## SceneKitで360度パノラマ画像ビューワーを実装する

ではSceneKitを使った360度パノラマ画像ビューワーの実装について説明します。
全容は[GitHub/RNSphereImageViewer](https://github.com/mothule/RNSphereImageViewer)で確認できます。
数ファイルしかないので、億劫にならないかと思います。


### SCNViewでSceneの描画先を決める

先の説明の通り、Sceneで描画計画を立てたら、それを実際に反映する先が必要になります。
映画でいうと映画館のスクリーンといったところです。

これはSCNViewと呼ばれる`UIView`のサブクラスを対象ViewControllerのviewに代入すれば終わりです。
以下は`viewDidLoad()`の抜粋です.

```swift
override open func viewDidLoad() {
  super.viewDidLoad()

  // 1. スクリーン先をviewにする
  let sceneView = SCNView()
  self.view = sceneView

  // 2. SCNSceneRendererDelegateで毎フレームフックする
  sceneView.delegate = self

  // 3. FPS指定
  sceneView.preferredFramesPerSecond = configuration.fps // FPSはSceneKitが管理している
  sceneView.rendersContinuously = true // これをtrueにしないと毎フレーム更新が呼ばれない

  // 4. その他
  sceneView.backgroundColor = UIColor.gray // 何も描画してないときの背景色. ライトとは違う色にすることをオススメします
  sceneView.autoenablesDefaultLighting = true
  sceneView.showsStatistics = true

  // 以下省略
}
```

#### 1. スクリーン先をviewにする

self.viewに対し SCNViewを指定することで投影先(スクリーン先)を設定します。


```swift
let sceneView = SCNView()
self.view = sceneView
```

SCNViewの初期化メソッドは、frameは描画領域、optionsは MetalやOpenGLなど`SCNRenderer`に渡すオプションになります。  
このoptionsは[MetalのSCNRenderer](https://developer.apple.com/documentation/scenekit/scnrenderer/1518404-init)や[OpenGLのSCNRenderer](https://developer.apple.com/documentation/scenekit/scnrenderer/1518408-init)は将来向けの拡張オプションでまだ使われていないようです。

```swift
SCNView.init(frame: CGRect, options: [String: Any]? = nil)
```

#### 2. SCNSceneRendererDelegateで毎フレームフックする
SCNView.delegateは `SCNSceneRendererDelegate` protocolになります。
これを採用すれば、SceneKitが行っている描画やアニメ処理、物理演算といったタイミングにフックすることができます。


```swift
sceneView.delegate = self
```

##### SceneKitがフレーム毎にしていること
SceneKitが何を行っているかについては、[公式](https://developer.apple.com/documentation/scenekit/scnscenerendererdelegate)にて解説されています。  
下の図は1フレーム※で行われている処理と各フックタイミングの解説です。  
※ 60FPSだとしたら、 1 / 60 ≒ 0.01667秒毎に呼ばれる。

{% page_image -3.png %}


今回は更新毎にカメラ制御などをしたいので[func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval)](https://developer.apple.com/documentation/scenekit/scnscenerendererdelegate/1522937-renderer)を使います。

##### デフォルトだと動かないと更新されない

SceneKitはデフォルト値だと、描画物やアニメ、物理演算など前フレームより変化がないと更新が実行されず、
同様にdelegateによるフックも呼び出されません。

これでは1フレーム毎に動かしたい、一定時間たったら動くなど、時間軸による制御が不可能なので、常にこれが呼ばれるようにする必要があります。
これは[SCNView.rendersContinuously](https://developer.apple.com/documentation/scenekit/scnview/2867339-renderscontinuously)として用意されてるので、これを`true`にすれば,後述するFPS値のレートで更新処理が行われます。

#### 3. FPS指定

FPSはSceneKitが管理しており、この値レートに従って更新されます。  
その値プロパティが[preferredFramesPerSecond](https://developer.apple.com/documentation/scenekit/scnview/1621205-preferredframespersecond)となります。  
この値はデフォルトでは60FPSとなっています。

```swift
sceneView.preferredFramesPerSecond = configuration.fps
sceneView.rendersContinuously = true
```

注意点が2点あり、FPSは処理負荷に依存するモニター値であるため、ここの値が実際のFPS値となるものではなく、指標としてのFPSとなります。
つまり60FPSであれば0.01秒に1回描画を行うように動きます。  
またもう1点は、与えられたFPSにそのまま適用するのではなくSceneKit内部で定めたできるだけ近いFPSを選択するようです。

[rendersContinuously](https://developer.apple.com/documentation/scenekit/scnview/2867339-renderscontinuously)は先程述べたように、これを`true`にしないと毎回FPSレートに呼ばれなくなります。

#### 4. その他

```swift
sceneView.backgroundColor = UIColor.gray // 何も描画してないときの背景色. ライトとは違う色にすることをオススメします
sceneView.autoenablesDefaultLighting = true
sceneView.showsStatistics = true
```

`backgroundColor`自体に説明は特に不要ですが、アドバイスとしては、SCNLightの色とは異なる色にしておくことをオススメします。
なぜなら最初の実装中は、ライトと同じ色にしていると描画されているのかどうか分からないためです。

例えば、背景を白、ライトを白の場合にしたとしましょう。  
この場合、 画面が真っ白だった場合に

- そもそもオブジェクトが描画されていない
- 描画されているが陰影処理が未適用まはライトが強すぎて視覚認識できない
- カメラが違う方向向いていてスクリーンに投影されていない

など複数要因が浮上し、原因特定に時間がかかるためです。

[autoenablesDefaultLighting](https://developer.apple.com/documentation/scenekit/scnscenerenderer/1523812-autoenablesdefaultlighting)はSceneに自動でライトを追加するかどうかを決めます。
`true`の場合、ライトなしかambientライトのみのときに、omnidirectionalなライトを自動で追加、配置します。

[showsStatistics](https://developer.apple.com/documentation/scenekit/scnscenerenderer/1522763-showsstatistics)はstatisticsを表示するフラグです。

`true`にして実行すると画面下にオーバーレイでviewが表示されます。

{% page_image -4.png %}

左側の+をタップすると、上記で解説したSceneKitがに行っている処理区分に分かれた負荷が表示されます。

{% page_image -5.png %}


### カメラをセット

viewの準備が出来たら、sceneを用意しnodeを追加してく作業になります。

まずカメラを追加します。最初にカメラである理由はなく、モデルやライトが先でも問題はないです。

```swift
let scene = SCNScene()
sceneView.scene = scene

let cameraNode = SCNNode()
cameraNode.camera = SCNCamera()
cameraNode.position = SCNVector3(0, 0, 0)
cameraNode.camera!.fieldOfView = CGFloat(configuration.fovy)
cameraNode.camera!.zFar = Double(configuration.zoomOutMax)
scene.rootNode.addChildNode(cameraNode)
self.cameraNode = cameraNode
```

`SCNode`という箱にcameraに対して `SCNCamera`をセットしたことでカメラとして使います。ダックタイピングみたいですね。。
`position`は`SCNCamera`の位置となります。
`camera`のFOVとZ-Farの値を設定します。
この値がなんなのかは、[公式](https://developer.apple.com/documentation/scenekit/scncamera)に解説があります。
ざっくり説明するとFOVが視野でZ-Farが見える距離です。

{% page_image -6.png %}

ちなみにFloatだったりSCNFloatだったりCGFloatだったりと型が統一されていません。ここらへんは後々統一されるといいですね。

### 球体モデルに画像を貼る
今回はGLKitで作ったときとは異なり、球体モデルは自作ではなくプリセットSCNSphereを使いました。
もしSCNSphereのTexture UV値が頂点情報になかったり、値がでたらめだったら、従来どおり自作する予定でした。

```swift
let sphere = SCNSphere(radius: 100)
sphere.segmentCount = configuration.segmentCount

let image = findImage(with: configuration)
sphere.materials.first?.diffuse.contents = image
sphere.materials.first?.isDoubleSided = true
let sphereNode = SCNNode(geometry:  sphere)
scene.rootNode.addChildNode(sphereNode)
modelNode = sphereNode
```

球体を作成し、画像を球体が持つマテリアル情報のdiffuse陰影に適用します。
diffuseに関しては[SCNMaterial.diffuse](https://developer.apple.com/documentation/scenekit/scnmaterial/1462589-diffuse)に説明があります。

とりあえず覚えることとしてはdiffuseは基礎カラーまたはテクスチャとして捉えといても構いません。  
diffuseの他にambientやmetalness,specularなどシェーダーがありますが、これらはシェーダー言語で自作することも可能です。  
とりあえず基本だから用意してくれているってだけです。  
頑張れば下図のような川瀬式シェーダーも可能になります。

{% page_image -7.png %}
(図は[Kawase 2003]より)

`isDoubleSided` はポリゴン面の法線を無視して両面に画像を表示するように支持しています。
これは360度パノラマ画像は球体の中から見ることを基本としてるためです。
本来であれば球体の法線を逆ベクトルにする方法もあるのですが、SCNSphereは予めモデリングされたものなので面毎に法線を反転となると再生成となり、元の球体自作と変わらないので、今回の形をとりました。

### ambientライトを用意

```swift
let ambientLightNode = SCNNode()
ambientLightNode.light = SCNLight()
ambientLightNode.light!.type = .ambient
ambientLightNode.light!.color = UIColor.white
scene.rootNode.addChildNode(ambientLightNode)
```
これは既に読めると思うので特に説明はせず省きます。

```swift
self.view.layer.magnificationFilter = CALayerContentsFilter.linear
self.view.layer.minificationFilter = CALayerContentsFilter.linear
```
これは受け取ったレイヤーに対する拡大と縮小時の補間フィルターアルゴリズムの選定です。


### SCNSceneRendererDelegateでフレーム更新を受け取る

前述したとおり、VCに対してSCNSceneRendererDelegateを採用しています。
GLKitのときの違いとしては、前回時間の算出方法が異なります。  
SceneKitでは自分で保持し算出する必要があります。

```swift
public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    let timeSinceLastUpdate = time - previousTime
    defer {
        previousTime = time
    }
    // 省略
}
```

また回転行列がYawPitchRollではなく任意軸になっているため、
Yawの回転比率に応じて、PitchとRollの値をcos/sinでだしてPitch軸を回転させていたのに対して  
任意軸となるため、そのままだと実質Roll軸の回転となってしまいます。

そのためカメラの上下回転に関しては、カメラの横のベクトルが必要となるので、元々求めている前ベクトルとYベクトルの２つを外積することで
カメラの横ベクトルを算出し、それを回転の任意軸として設定することで、カメラの上下回転を実現しました。

### あとは同じ

あとはほとんど前回と同じになります。

## GLKitと異なり躓いたポイント

- 動かないとupdateが呼ばれない
- 回転行列がYawPitchRollの3軸ではなく任意軸

## まとめ

以上, 実際にやってみたら躓きポイント、特に回転行列APIが任意軸になってる部分で大分気づくのに時間がかかりました。
今回GLKitからSceneKitに差し替えたことで、SceneKitの手軽さを体験できたことは良かったなと思いました。

Unityであればリソースアセット管理とそれの編集などトータル的に勝ってはいますが、
ここまでグラフィカルエンジンのことを気にせず3Dコンテンツに集中できるとなると、ちょっと元ゲーム開発者としてはゲームを作ってみようかなと心がソワソワしました。
