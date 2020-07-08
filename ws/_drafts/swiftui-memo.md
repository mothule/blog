# SwiftUI

View
UIHostingController
environmentObject
@EnvironmentObject
VStack(alignment: spacing: content:)
HStack(alignment: spacing: content:)
ZStack(alignment: content:)
.padding()
.offset()
.aspectRatio(_:contentMode:)

@Binding
@State
UIViewRepresentable
UIViewControllerRepresentable
GeometryReader
Path
.move(to:)
.addLine(to:)
.fill(_:)
List
Text
.bold
.font
ScrollView(.horizontal)
.hueRotation
.grayscale
Angle
.frame
.accessibility(label:)
.resizable()
.overlay()
.foregroundColor(UIColor)
Divider()
TextField(:text:)
Toogle(isOn:){}
Picker(:selection:){}
ForEach(Data, KeyPath){}
.pickerStyle()
DatePicker()
.animation(nil)
Image()
.imageScale()
.scaledToFill()
.clipped()
.listRowInsets(EdgeInsets())
NavigationLink(destination:){}
NavigationView
.navigationBarTitle()
.navigationBarItems()
.sheet(isPresented:){}
Button(:){}
Spacer()
EditButton()
@Environment(\.editMode)
.onAppear{}
.onDisappear{}
.opacity()
.rotationEffect(_:,anchor:)
extension AnyTransition{}
AnyTransition.move(edge:)
.combined(with:)
AnyTransition.scale
.asymmetric(insertion:removal:)
Button(action: {withAnimation{}})
Group{}
.previewLayout(.fixed())
ForEach(["iPhone SE", "iPhone XS Max"])
.previewDevice(PreviewDevice(rawValue:String))
.previewDisplayName()
.clipShape(Circle())
.overlay(Circle().stroke(:,lineWidth))
.shadow(radius:)
