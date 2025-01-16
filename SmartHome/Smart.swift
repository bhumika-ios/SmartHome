//
//  Smart.swift
//  SmartHome
//
//  Created by Bhumika Patel on 11/01/25.
//


import SwiftUI
import Lottie
import EffectsLibrary

struct SmartHomeView1: View {
    @State private var isLightOn: Bool = true
    @State private var isACOn: Bool = false
    @State private var navigateToACControl: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("Hi, Michael")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("A total of 4 devices")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Button(action: {
                        // Action for profile
                    }) {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.primary)
                            )
                    }
                }
                .padding()

                // Devices Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    DeviceCard(color: .red, icon: "lightbulb", label: "Smart Spotlight", isOn: $isLightOn)
                    NavigationLink(destination: SmartACControlView(), isActive: $navigateToACControl) {
                        DeviceCard(color: .blue, icon: "air.conditioner.horizontal.fill", label: "Smart AC", isOn: $isACOn)
                    }
                    .isDetailLink(false)
                    DeviceCard(color: .green, icon: "tv", label: "Smart TV", isOn: .constant(false))
                    DeviceCard(color: .purple, icon: "speaker.wave.2", label: "Smart Sound", isOn: .constant(false))
                }
                .padding()

                Spacer()
            }
        }
        .tint(Color.black)
    }
}



struct DeviceCard: View {
    let color: Color
    let icon: String
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(isOn ? color.opacity(0.7) : color.opacity(0.2)) // Dark color when on, light when off
                                .frame(height: 250)
                .overlay(
                    VStack(alignment: .leading) {
                        Image(systemName: icon)
                            .font(.system(size: 45))
                            .foregroundColor(isOn ? .white : .black)
                            .padding()
                        // Change text color based on the state of isOn
                        Text(label)
                            .font(.title)
                            .foregroundColor(isOn ? .white : .black)
                        
                        Spacer()
                        
                        Toggle("", isOn: $isOn)
                            .labelsHidden()
                    }
                    .padding()
                )
        }
    }
}

struct SmartACControlView: View {
    @State private var temperature: Double = 24.0
    @State private var speed: Int = 1
    @State private var powerOn: Bool = false

    var body: some View {
        ZStack {
            // Background Gradient based on temperature
            LinearGradient(
                gradient: Gradient(colors: backgroundColors(for: temperature)),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Spacer()

                // Temperature Control with circular progress
                VStack {
                    // Circle with progress
                    ZStack {
                        
                        SmokeExample(rawValue: speed)?.view()
                            .offset(y: 10)
                            .opacity(powerOn ? 1 : 0)
                        Circle()
                            .fill(.white)
                            .strokeBorder(Color.white.opacity(0.2), lineWidth: 1) // Background ring
                            .frame(width: 150, height: 150)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat((temperature - 16) / 14)) // Processing ring (based on temperature)
                            .stroke(style: StrokeStyle(lineWidth: 30, lineCap: .square, lineJoin: .bevel))
                            .foregroundColor(processingColor(for: temperature))
                            .rotationEffect(.degrees(90)) // Rotate so the progress starts from top
                            .frame(width: 180, height: 180)
                        
                        // Temperature display in the center of the circle
                        Text("\(Int(temperature))°C")
                            .font(.system(size: 40))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                    }
                    .padding(-50)
                }

                // Power & Speed Controls
                VStack {
                    HStack(spacing: 0) {
                        VStack(alignment: .leading) {
                            Text("Speed")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            // Circle speed selector
                            HStack(spacing: 10) {
                                ForEach(SmokeExample.allCases, id: \.rawValue) { smoke in
                                       Circle()
                                           .fill(smoke.rawValue == speed ? Color.white : processingColor(for: temperature))
                                           .frame(width: 50, height: 50)
                                           .overlay(
                                               Text("\(smoke.rawValue)")
                                                   .fontWeight(.bold)
                                                   .foregroundColor(smoke.rawValue == speed ? .black : .white)
                                           )
                                           .onTapGesture {
                                               speed = smoke.rawValue
                                           }
                                   }
                            }
                        }
                        .padding(10)
                        .background{
                            processingColor(for: temperature)
                        }
                        .cornerRadius(15)
                        .padding(.horizontal,6)
                        
                        VStack(alignment: .leading) {
                            Text("Power")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            HStack {
                                Text("On")
                                    .font(.system(size: 20))
                                    .fontWeight(.bold)
                                    .foregroundColor(powerOn ? .white : .white.opacity(0.2))
                                Text("/")
                                Text("off")
                                    .font(.system(size: 20))
                                    .fontWeight(.bold)
                                    .foregroundColor(powerOn ? .white.opacity(0.2) : .white)
                                
                                Toggle("", isOn: $powerOn)
                                    .labelsHidden()
                                    .toggleStyle(SwitchToggleStyle(tint: .white.opacity(0.2)))
                
                            }
                        }
                        .padding(19)
                        .background{
                            processingColor(for: temperature)
                        }
                        .cornerRadius(15)
                    }
                }
                .padding(.vertical)
                .padding(.horizontal,-10)

                // Temperature Slider
                VStack(alignment: .leading) {
                    Text("Temp")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    HStack {
                        Text("16°C")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Slider(value: $temperature, in: 16...30, step: 1)
                            .accentColor(.white)
                            .padding()
                        Text("30°C")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background{
                    processingColor(for: temperature)
                }
                .cornerRadius(15)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Smart Ac")
        
    }

    // Helper function to define gradient colors based on the temperature
    private func backgroundColors(for temperature: Double) -> [Color] {
        switch temperature {
        case 16...17:
            return [Color("sky").opacity(0.2), Color("sky").opacity(0.8)]
        case 18...19:
            return [Color("Darksky").opacity(0.2), Color("Darksky").opacity(0.8)]
        case 20...21:
            return [Color("blue").opacity(0.2), Color("blue").opacity(0.8)]
        case 22...23:
            return [Color("purple").opacity(0.2), Color("purple").opacity(0.8)]
        case 24...25:
            return [Color("darkpurple").opacity(0.2), Color("darkpurple").opacity(0.8)]
        case 26...27:
            return [Color("Pink").opacity(0.2), Color("Pink").opacity(0.8)]
        case 28:
            return [Color("DarkPink").opacity(0.2), Color("DarkPink").opacity(0.8)]
        case 29...30:
            return [Color.red.opacity(0.2), Color.red.opacity(0.8)]
        default:
            return [Color.white, Color.white]
        }
    }
    
    // Helper function to adjust the processing line color based on temperature
    private func processingColor(for temperature: Double) -> Color {
        switch temperature {
        case 16...17:
            return Color("sky")
        case 18...19:
            return Color("Darksky")
        case 20...21:
            return Color("blue")
        case 22...23:
            return Color("purple")
        case 24...25:
            return Color("darkpurple")
        case 26...27:
            return Color("Pink")
        case 28:
            return Color("DarkPink")
        case 29...30:
            return Color.red
        default:
            return Color.white
        }
    }
}
struct LottieView: UIViewRepresentable {
    var name: String
    var loopMode: LottieLoopMode

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)

        let animationView = LottieAnimationView()
        if let animation = LottieAnimation.named(name) {
            animationView.animation = animation
        } else {
            print("Failed to load Lottie animation named: \(name)")
        }
        animationView.contentMode = .scaleAspectFill
        animationView.loopMode = loopMode
        animationView.play()

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
struct SmartHomeView1_Previews: PreviewProvider {
    static var previews: some View {
        SmartHomeView1()
    }
}
