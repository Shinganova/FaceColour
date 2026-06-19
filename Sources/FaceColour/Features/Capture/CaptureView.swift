import SwiftUI
import PhotosUI

/// Phase 1 home screen: take or choose a selfie, then confirm a face is detected.
struct CaptureView: View {
    @State private var vm = CaptureViewModel()
    @State private var pickerItem: PhotosPickerItem?
    @State private var showCamera = false

    private var cameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                imageArea
                statusView
                if let result = vm.skinResult {
                    SkinToneResultCard(result: result)
                }
                Spacer(minLength: 0)
                actionButtons
            }
            .padding()
            .navigationTitle("FaceColour")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showCamera) {
            CameraPicker { image in
                Task { await vm.setImage(image) }
            }
            .ignoresSafeArea()
        }
        .onChange(of: pickerItem) { _, item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await vm.setImage(image)
                }
                pickerItem = nil
            }
        }
    }

    // MARK: - Image

    @ViewBuilder
    private var imageArea: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))

            if let image = vm.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .overlay {
                        FaceOverlayView(imageSize: vm.imagePixelSize,
                                        faces: vm.faces,
                                        patches: vm.samplePatches)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "face.dashed")
                        .font(.system(size: 56))
                        .foregroundStyle(.secondary)
                    Text("Take or choose a selfie to begin.")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }

            if vm.state == .detecting {
                ProgressView().controlSize(.large)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 420)
    }

    // MARK: - Status

    @ViewBuilder
    private var statusView: some View {
        switch vm.state {
        case .empty, .detecting:
            EmptyView()
        case .detected(let count):
            Label(count == 1 ? "Face detected" : "\(count) faces detected",
                  systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
        case .noFace:
            Label("No face found — try better lighting and face the camera.",
                  systemImage: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
                .multilineTextAlignment(.center)
        case .failed(let message):
            Label(message, systemImage: "xmark.octagon.fill")
                .foregroundStyle(.red)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Actions

    @ViewBuilder
    private var actionButtons: some View {
        VStack(spacing: 12) {
            if cameraAvailable {
                Button {
                    showCamera = true
                } label: {
                    Label("Take Photo", systemImage: "camera.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }

            PhotosPicker(selection: $pickerItem, matching: .images, photoLibrary: .shared()) {
                Label("Choose Photo", systemImage: "photo.on.rectangle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

            if vm.image != nil {
                Button(role: .destructive) {
                    vm.reset()
                } label: {
                    Text("Clear").frame(maxWidth: .infinity)
                }
                .controlSize(.large)
            }
        }
    }
}

#Preview {
    CaptureView()
}
