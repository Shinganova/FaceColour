import SwiftUI
import PhotosUI

/// Home screen: take/choose a selfie, see the analysis, save or share it.
struct CaptureView: View {
    let history: HistoryStore

    @State private var vm = CaptureViewModel()
    @State private var pickerItem: PhotosPickerItem?
    @State private var showCamera = false
    @State private var showHistory = false
    @State private var showShop = false
    @State private var saved = false

    private var cameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        imageArea
                        statusView
                        results
                    }
                    .padding()
                }
                actionButtons
                    .padding()
                    .background(.bar)
            }
            .navigationTitle("FaceColour")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showHistory = true } label: {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                    .accessibilityLabel("History")
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraPicker { image in
                Task { await vm.setImage(image) }
            }
            .ignoresSafeArea()
        }
        .sheet(isPresented: $showHistory) {
            HistoryListView(store: history)
        }
        .sheet(isPresented: $showShop) {
            ShopView(season: vm.season, monkTone: vm.shadeMatches.first?.tone.tone)
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
        .onChange(of: vm.skinResult) { _, _ in saved = false }
    }

    // MARK: - Results

    @ViewBuilder
    private var results: some View {
        if let skin = vm.skinResult, let season = vm.season {
            ResultsView(representativeRGB: skin.representativeRGB,
                        undertone: skin.undertone,
                        fitzpatrick: skin.fitzpatrick,
                        confidence: skin.confidence,
                        season: season,
                        guide: vm.seasonGuide,
                        shadeMatches: vm.shadeMatches)
            resultActions(skin: skin, season: season)
            Button {
                showShop = true
            } label: {
                Label("Shop your colors", systemImage: "bag.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        } else if case .detected = vm.state {
            Label("Couldn't read skin reliably — try better lighting and face the camera.",
                  systemImage: "exclamationmark.triangle")
                .foregroundStyle(.orange)
                .multilineTextAlignment(.center)
        }
    }

    @ViewBuilder
    private func resultActions(skin: SkinToneResult, season: Season) -> some View {
        HStack(spacing: 12) {
            Button {
                if let record = vm.makeRecord() {
                    history.add(record, thumbnail: vm.image?.thumbnail())
                    saved = true
                }
            } label: {
                Label(saved ? "Saved" : "Save",
                      systemImage: saved ? "checkmark" : "square.and.arrow.down")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(saved)

            ShareLink(item: AnalysisSummary.text(season: season,
                                                 undertone: skin.undertone,
                                                 fitzpatrick: skin.fitzpatrick,
                                                 closestTone: vm.shadeMatches.first?.tone.tone)) {
                Label("Share", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
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
    CaptureView(history: HistoryStore())
}
