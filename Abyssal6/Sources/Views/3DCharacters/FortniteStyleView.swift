//
//  FortniteStyleView.swift
//  3dViewer
//
//  Created by Arkadiy KAZAZYAN on 23/05/2026.
//

import SwiftUI
import RealityKit
import QuartzCore

struct FortniteStyleView: View {

    @State private var rootEntity: RealityKit.Entity?
    @State private var isLoading = true
    @State private var loadProgress = 0
    @State private var rotationAngle: Float = 0
    private let rotationSpeed: Float = 0.1 // radians per second

    @State private var displayLinkManager = DisplayLinkManager()
    @State private var viewModel = FortniteStyleModel()

    private let circleRadius: Float = 2.2
    private let pedestalHeight: Float = 0.05
    private let pedestalRadius: Float = 0.35

    var body: some View {
        ZStack {
            Image("back") // Make sure "back.png" is added to your asset catalog
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()

            RealityView { content in
                let root = RealityKit.Entity()
                root.name = "RootEntity"
                root.position = SIMD3<Float>(0, -1.0, -2.5)
                content.add(root)
                rootEntity = root

                setupLighting(in: content)
                await loadAllCharacters(into: root)

            } update: { _ in }
                .ignoresSafeArea()
                .onAppear {
                    displayLinkManager.onUpdate = { duration in
                        guard !isLoading else { return }
                        rotationAngle += Float(duration) * rotationSpeed
                        let rotation = simd_quatf(angle: rotationAngle, axis: [0, 1, 0])
                        rootEntity?.orientation = rotation
                    }
                    displayLinkManager.start()
                }
                .onDisappear {
                    displayLinkManager.stop()
                }

            if isLoading {
                VStack(spacing: 16) {
                    ProgressView(value: Double(loadProgress), total: Double(viewModel.models.count))
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    Text("Loading characters... \(loadProgress)/\(viewModel.models.count)")
                        .font(.caption)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.6))
            }
            VStack {
                Text("ABYSSAL-6")
                // Size scales proportionally with device height
                    .font(.system(size: 40, weight: .black, design: .monospaced))
                    .foregroundColor(.abyssalText)
                    .shadow(color: .abyssalAccent.opacity(0.8), radius: 12 )
                    .padding(.top, 30)
                Spacer()

                HStack {
                    Spacer()
                    AbyssalButton(title: "Next", color: .abyssalAccent, scaleY: 1.5) {
                        viewModel.showIntro()
                    }
                    .padding(.trailing, 60)
                }
                .padding(.bottom, 30)
            }
            .ignoresSafeArea()
        }
        .preferredColorScheme(.dark)
        .onAppear {
            viewModel.playBackgroundMusic("theme")
        }
    }

    // MARK: - Lighting (fixed)
    private func setupLighting(in content: RealityViewCameraContent) {
        // Ambient light
        let ambientLightComponent = DirectionalLightComponent(
            color: .white,
            intensity: Float(300 * 3.0),
            isRealWorldProxy: false
        )
        let ambientLightEntity = RealityKit.Entity()
        ambientLightEntity.components.set(ambientLightComponent)
        content.add(ambientLightEntity)

        // Main directional light (key light)
        let directionalLightEntity = RealityKit.Entity()
        directionalLightEntity.components.set(DirectionalLightComponent(color: .white, intensity: 1.2))
        directionalLightEntity.orientation = simd_quatf(angle: .pi / 4, axis: [1, 0, 0])
        content.add(directionalLightEntity)

        // Fill light (point light)
        let fillLightEntity = RealityKit.Entity()
        fillLightEntity.components.set(PointLightComponent(color: .init(red: 0.8, green: 0.9, blue: 1.0, alpha: 1.0), intensity: 0.5))
        fillLightEntity.position = [0, 1.5, -2.5]
        content.add(fillLightEntity)

        // Warm back rim light
        let rimLightEntity = RealityKit.Entity()
        rimLightEntity.components.set(PointLightComponent(color: .init(red: 1.0, green: 0.7, blue: 0.4, alpha: 1.0), intensity: 0.6))
        rimLightEntity.position = [0, 1.8, 3.0]
        content.add(rimLightEntity)
    }

    // MARK: - Load and place all characters
    @MainActor
    private func loadAllCharacters(into root: RealityKit.Entity) async {
        isLoading = true

        let count = viewModel.models.count
        for (index, model) in viewModel.models.enumerated() {
            loadProgress = index + 1

            guard let characterEntity = try? await ModelEntity(named: model.name) else {
                print("Failed to load \(model.name)")
                continue
            }

            let angle = (Float(index) / Float(count)) * 2 * .pi
            let pedestalX = circleRadius * cos(angle)
            let pedestalZ = circleRadius * sin(angle)
            let position = SIMD3<Float>(pedestalX, pedestalHeight, pedestalZ)

            let pedestal = createPedestal()
            pedestal.position = position

            // Place character on top of pedestal
            let characterBounds = characterEntity.visualBounds(relativeTo: nil)
            let pedestalTopY = pedestalHeight + 0.05
            let yOffset = pedestalTopY - characterBounds.min.y
            characterEntity.position = SIMD3<Float>(0, yOffset, 0)
            characterEntity.scale = SIMD3<Float>(repeating: 0.85)

            let outwardAngle = atan2(pedestalX, pedestalZ)
            let outwardRotation = simd_quatf(angle: outwardAngle, axis: [0, 1, 0])
            characterEntity.orientation = outwardRotation

            // Add name label above the character
            let textEntity = createTextEntity(Lang.string(model.displayName))
            // Position above the head: character's top + small gap
            let headTopY = characterBounds.max.y - 0.12
            textEntity.position = SIMD3<Float>(0, headTopY, 0)
            textEntity.scale = SIMD3<Float>(repeating: 0.6)
            // Orient text to face outward (same as character) for readability
            textEntity.orientation = outwardRotation

            pedestal.addChild(characterEntity)
            pedestal.addChild(textEntity)
            root.addChild(pedestal)

            try? await Task.sleep(nanoseconds: 50_000_000)
        }

        isLoading = false
        loadProgress = viewModel.models.count
    }

    // MARK: - Pedestal (fixed: no torus, uses a thin disc ring)
    private func createPedestal() -> RealityKit.Entity {
        let cylinder = ModelEntity(
            mesh: .generateCylinder(height: pedestalHeight, radius: pedestalRadius),
            materials: [SimpleMaterial(color: .darkGray, isMetallic: true)]
        )

        // Glowing ring – a very thin disc that looks like a ring
        let ringDisc = ModelEntity(
            mesh: .generateCylinder(height: 0.025, radius: pedestalRadius - 0.05),
            materials: [SimpleMaterial(color: .cyan, roughness: 0.2, isMetallic: true)]
        )
        ringDisc.position.y = pedestalHeight / 2 + 0.025
        cylinder.addChild(ringDisc)

        // Top platform
        let topDisc = ModelEntity(
            mesh: .generateCylinder(height: 0.025, radius: pedestalRadius + 0.05),
            materials: [SimpleMaterial(color: .lightGray, roughness: 0.2, isMetallic: true)]
        )
        topDisc.position.y = -pedestalHeight / 2 + 0.025
        cylinder.addChild(topDisc)

        return cylinder
    }

    private func createTextEntity(_ text: String, color: UIColor = .yellow) -> ModelEntity {
        let mesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.02,
            font: .systemFont(ofSize: 0.1),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )
        let material = SimpleMaterial(color: color, isMetallic: false)
        let textMesh = ModelEntity(mesh: mesh, materials: [material])

        // Get the bounding box of the text mesh
        let bounds = textMesh.visualBounds(relativeTo: nil)
        // Shift so that the centre of the text is at (0,0,0) in the container
        textMesh.position = SIMD3<Float>(-bounds.center.x, -bounds.center.y, -bounds.center.z)

        let container = ModelEntity()
        container.addChild(textMesh)
        return container
    }
}

#Preview {
    FortniteStyleView()
}
