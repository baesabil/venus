import SwiftUI
import PhotosUI
import PencilKit

/// Editor cover dengan 3 mode:
/// - Photo : pilih foto, geser & cubit untuk atur posisi/zoom
/// - Text  : tambah teks, pilih font/warna/ukuran, geser di atas cover
/// - Draw  : coret langsung pakai jari
struct CoverEditorView: View {
    @Bindable var vm: NoteEditorViewModel
    @Environment(\.dismiss) private var dismiss

    enum Mode: String, CaseIterable { case photo = "Photo", text = "Text", draw = "Draw" }

    @State private var mode: Mode = .photo
    @State private var selectedID: UUID?
    @State private var pickedItem: PhotosPickerItem?

    // Titik awal gesture foto
    @State private var baseOffset: CGSize = .zero
    @State private var baseScale: CGFloat = 1

    // Pengaturan pena
    @State private var penColor = 1
    @State private var penWidth: CGFloat = 6
    @State private var isEraser = false

    private var currentTool: PKTool {
        isEraser
            ? PKEraserTool(.vector)
            : PKInkingTool(.pen, color: UIColor(CoverPalette.color(penColor)), width: penWidth)
    }

    var body: some View {
        VStack(spacing: 16) {
            header
            canvasArea
            modePicker
            ScrollView {
                controls.padding(.horizontal, 20).padding(.bottom, 30)
            }
        }
        .background(Theme.background.ignoresSafeArea())
        .onAppear {
            baseOffset = vm.photoOffset
            baseScale = vm.photoScale
        }
        .onChange(of: pickedItem) { _, item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    vm.setCoverPhoto(data: data)
                    baseOffset = .zero
                    baseScale = 1
                }
                pickedItem = nil
            }
        }
    }

    // MARK: - Bagian atas

    private var header: some View {
        HStack {
            Text("Cover").font(.title2.bold()).foregroundStyle(Theme.ink)
            Spacer()
            CircleIconButton(systemName: "checkmark", isDark: true) { dismiss() }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }

    private var canvasArea: some View {
        GeometryReader { geo in
            let scale = geo.size.width / CoverCanvasView.side
            ScaledCoverContainer {
                ZStack {
                    CoverCanvasView(
                        baseImage: vm.baseImage,
                        photoScale: vm.photoScale,
                        photoOffset: vm.photoOffset,
                        layers: $vm.layers,
                        selectedID: $selectedID,
                        drawing: vm.drawing,
                        showDrawing: mode != .draw,
                        isInteractive: mode == .text
                    )
                    if mode == .draw {
                        DrawingCanvas(drawing: $vm.drawing, tool: currentTool)
                            .frame(width: CoverCanvasView.side, height: CoverCanvasView.side)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card, style: .continuous))
            .gesture(photoGesture(scale: scale), including: mode == .photo ? .all : .subviews)
        }
        .aspectRatio(1, contentMode: .fit)
        .padding(.horizontal, 20)
    }

    /// Geser & cubit untuk memposisikan foto (aktif hanya di mode Photo).
    private func photoGesture(scale: CGFloat) -> some Gesture {
        SimultaneousGesture(DragGesture(), MagnifyGesture())
            .onChanged { value in
                if let drag = value.first {
                    vm.photoOffset = CGSize(
                        width: baseOffset.width + drag.translation.width / scale / CoverCanvasView.side,
                        height: baseOffset.height + drag.translation.height / scale / CoverCanvasView.side
                    )
                }
                if let magnify = value.second {
                    vm.photoScale = min(max(baseScale * magnify.magnification, 1), 4)
                }
            }
            .onEnded { _ in
                baseOffset = vm.photoOffset
                baseScale = vm.photoScale
            }
    }

    private var modePicker: some View {
        HStack(spacing: 8) {
            ForEach(Mode.allCases, id: \.self) { item in
                Button {
                    HapticsManager.shared.tick()
                    withAnimation(.snappy) { mode = item }
                } label: {
                    Text(item.rawValue)
                        .font(.subheadline.weight(.semibold))
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(mode == item ? Theme.ink : Theme.surface, in: Capsule())
                        .foregroundStyle(mode == item ? Color.white : Theme.ink)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Panel kontrol per mode

    @ViewBuilder
    private var controls: some View {
        switch mode {
        case .photo: photoControls
        case .text:  textControls
        case .draw:  drawControls
        }
    }

    private var photoControls: some View {
        VStack(spacing: 12) {
            if vm.baseImage != nil {
                Text("Drag to move · Pinch to zoom")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            PhotosPicker(selection: $pickedItem, matching: .images) {
                Label(vm.baseImage == nil ? "Choose a photo" : "Change photo", systemImage: "photo")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.ink, in: Capsule())
                    .foregroundStyle(.white)
            }
        }
    }

    private var textControls: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button {
                HapticsManager.shared.tap()
                selectedID = vm.addTextLayer()
            } label: {
                Label("Add text", systemImage: "textformat")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.ink, in: Capsule())
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)

            if let index = vm.layers.firstIndex(where: { $0.id == selectedID }) {
                TextField("Your text", text: $vm.layers[index].text)
                    .padding(14)
                    .background(Theme.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                FontPickerRow(selection: $vm.layers[index].fontIndex)
                ColorPickerRow(selection: $vm.layers[index].colorIndex)

                labeledSlider("Size", value: $vm.layers[index].size, range: 0.06...0.4)
                labeledSlider("Rotate", value: $vm.layers[index].rotation, range: -45...45)

                Button(role: .destructive) {
                    vm.deleteLayer(vm.layers[index].id)
                    selectedID = nil
                } label: {
                    Label("Delete text", systemImage: "trash").font(.subheadline)
                }
            } else {
                Text("Tap a text on the cover to edit it, or drag it to move.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var drawControls: some View {
        VStack(alignment: .leading, spacing: 16) {
            ColorPickerRow(selection: $penColor)
            labeledSlider("Width", value: $penWidth, range: 2...24)

            HStack(spacing: 10) {
                toolButton(isEraser ? "pencil.tip" : "eraser", title: isEraser ? "Pen" : "Eraser") {
                    isEraser.toggle()
                }
                toolButton("arrow.uturn.backward", title: "Undo") {
                    guard !vm.drawing.strokes.isEmpty else { return }
                    var strokes = vm.drawing.strokes
                    strokes.removeLast()
                    vm.drawing = PKDrawing(strokes: strokes)
                }
                toolButton("trash", title: "Clear") {
                    vm.drawing = PKDrawing()
                }
            }
        }
    }

    private func labeledSlider<V: BinaryFloatingPoint>(_ title: String, value: Binding<V>, range: ClosedRange<V>) -> some View where V.Stride: BinaryFloatingPoint {
        HStack {
            Text(title).font(.subheadline.weight(.semibold)).frame(width: 60, alignment: .leading)
            Slider(value: value, in: range).tint(Theme.ink)
        }
    }

    private func toolButton(_ icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button {
            HapticsManager.shared.tap()
            action()
        } label: {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Theme.surface, in: Capsule())
                .foregroundStyle(Theme.ink)
        }
        .buttonStyle(.plain)
    }
}
