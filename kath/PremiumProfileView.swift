import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import PhotosUI

struct PremiumProfileView: View {
    @State private var name = ""
    @State private var age = ""
    @State private var phone = ""
    @State private var location = ""
    @State private var occupation = ""
    @State private var bio = "Share something about yourself..."
    
    @State private var isEditing = false
    @State private var isLoading = false
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImage: UIImage?
    @State private var isUploadingImage = false
    @State private var profileImageUrl: String = ""
    @State private var showLogoutConfirmation = false
    
    // Premium Colors
    let primaryColor = Color(red: 0.08, green: 0.25, blue: 0.75)
    let accentColor = Color(red: 0.9, green: 0.3, blue: 0.25)
    let backgroundColor = Color(red: 0.97, green: 0.97, blue: 0.98)
    let cardColor = Color.white
    let gradientStart = Color(red: 0.1, green: 0.3, blue: 0.8)
    let gradientEnd = Color(red: 0.5, green: 0.2, blue: 0.9)
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    var userId: String {
        Auth.auth().currentUser?.uid ?? ""
    }
    
    var userEmail: String {
        Auth.auth().currentUser?.email ?? ""
    }
    
    var userName: String {
        Auth.auth().currentUser?.displayName ?? ""
    }
    
    // Animation States
    @State private var headerScale: CGFloat = 1.0
    @State private var cardOffset: CGFloat = 50
    @State private var cardOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [backgroundColor, backgroundColor.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Content
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Header Section
                    headerSection
                        .scaleEffect(headerScale)
                    
                    // Stats Section (Minimal)
                    statsSection
                    
                    // Action Buttons
                    actionButtonsSection
                        .offset(y: cardOffset)
                        .opacity(cardOpacity)
                    
                    // Profile Details Card
                    profileCardSection
                        .offset(y: cardOffset)
                        .opacity(cardOpacity)
                    
                    // Logout Button
                    logoutSection
                        .offset(y: cardOffset + 20)
                        .opacity(cardOpacity)
                }
            }
            .refreshable {
                await refreshProfile()
            }
            
            // Loading Overlay
            if isLoading {
                loadingOverlay
            }
            
            // Toast Notification
            if showToast {
                toastNotification
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Logout", isPresented: $showLogoutConfirmation) {
            Button("Logout", role: .destructive) {
                logoutUser()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to logout?")
        }
        .onAppear {
            loadUserProfileWithAnimation()
        }
        .onChange(of: selectedPhoto) { newItem in
            Task {
                await handlePhotoSelection(newItem)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 24) {
            // Profile Picture with Shine Effect
            ZStack {
                if let profileImage = profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(LinearGradient(colors: [gradientStart, gradientEnd], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 4)
                        )
                        .shadow(color: primaryColor.opacity(0.3), radius: 15, x: 0, y: 8)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                        )
                } else if !profileImageUrl.isEmpty {
                    AsyncImage(url: URL(string: profileImageUrl)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(LinearGradient(colors: [gradientStart, gradientEnd], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 4)
                            )
                            .shadow(color: primaryColor.opacity(0.3), radius: 15, x: 0, y: 8)
                    } placeholder: {
                        Circle()
                            .fill(LinearGradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 120, height: 120)
                            .overlay(
                                ProgressView()
                                    .tint(.white)
                            )
                    }
                } else {
                    Circle()
                        .fill(LinearGradient(colors: [gradientStart, gradientEnd], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 120, height: 120)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 45, weight: .medium))
                                .foregroundColor(.white)
                        )
                        .shadow(color: primaryColor.opacity(0.3), radius: 15, x: 0, y: 8)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                        )
                }
                
                // Camera Button
                if isEditing {
                    PhotosPicker(selection: $selectedPhoto,
                               matching: .images,
                               photoLibrary: .shared()) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(accentColor)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 3))
                            .shadow(radius: 5)
                    }
                               .offset(x: 40, y: 40)
                }
            }
            .padding(.top, 10)
            
            // User Info
            VStack(spacing: 8) {
                Text(name.isEmpty ? userName : name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text(userEmail)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                if !occupation.isEmpty && !isEditing {
                    Text(occupation)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(primaryColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(primaryColor.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 30)
        .background(
            LinearGradient(
                colors: [gradientStart.opacity(0.05), gradientEnd.opacity(0.02)],
                startPoint: .top,
                endPoint: .bottom
            )
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(LinearGradient(colors: [gradientStart.opacity(0.1), .clear], startPoint: .top, endPoint: .bottom), lineWidth: 1)
            )
        )
    }
    
    // MARK: - Stats Section (Minimal)
    private var statsSection: some View {
        HStack(spacing: 30) {
            StatItem(value: "🌟", title: "Premium")
            StatItem(value: "✅", title: "Verified")
            StatItem(value: "📱", title: "Active")
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Action Buttons
    private var actionButtonsSection: some View {
        HStack(spacing: 16) {
            if isEditing {
                // Cancel Button
                Button(action: cancelEditing) {
                    ActionButton(
                        icon: "xmark",
                        title: "Cancel",
                        color: .red,
                        isPrimary: false
                    )
                }
                
                // Save Button
                Button(action: saveProfile) {
                    ActionButton(
                        icon: isLoading ? "" : "checkmark",
                        title: isLoading ? "Saving..." : "Save",
                        color: primaryColor,
                        isPrimary: true,
                        isLoading: isLoading
                    )
                }
                .disabled(isLoading)
            } else {
                // Edit Profile Button
                Button(action: startEditing) {
                    ActionButton(
                        icon: "pencil",
                        title: "Edit Profile",
                        color: primaryColor,
                        isPrimary: false
                    )
                }
                
                // Refresh Button
                Button(action: {
                    Task {
                        await refreshProfile()
                    }
                }) {
                    ActionButton(
                        icon: "arrow.clockwise",
                        title: "Refresh",
                        color: .green,
                        isPrimary: false
                    )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    // MARK: - Profile Card
    private var profileCardSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Card Header
            HStack {
                Image(systemName: "person.text.rectangle.fill")
                    .foregroundColor(primaryColor)
                    .font(.system(size: 18))
                
                Text("Personal Information")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if !isEditing {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            
            Divider()
                .background(Color.gray.opacity(0.2))
            
            // Profile Fields
            LazyVStack(spacing: 0) {
                PremiumProfileField(
                    icon: "person.fill",
                    title: "Full Name",
                    value: $name,
                    isEditing: isEditing,
                    placeholder: "Enter your full name"
                )
                
                PremiumProfileField(
                    icon: "calendar",
                    title: "Age",
                    value: $age,
                    isEditing: isEditing,
                    placeholder: "Your age",
                    keyboardType: .numberPad
                )
                
                PremiumProfileField(
                    icon: "phone.fill",
                    title: "Phone",
                    value: $phone,
                    isEditing: isEditing,
                    placeholder: "+91 1234567890",
                    keyboardType: .phonePad
                )
                
                PremiumProfileField(
                    icon: "briefcase.fill",
                    title: "Occupation",
                    value: $occupation,
                    isEditing: isEditing,
                    placeholder: "What do you do?"
                )
                
                PremiumProfileField(
                    icon: "location.fill",
                    title: "Location",
                    value: $location,
                    isEditing: isEditing,
                    placeholder: "Your city or country"
                )
                
                // Bio Section
                bioSection
            }
        }
        .background(cardColor)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 5)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    // MARK: - Bio Section
    private var bioSection: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "text.quote")
                .foregroundColor(primaryColor)
                .font(.system(size: 16))
                .frame(width: 20)
                .padding(.top, 4)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("About Me")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                if isEditing {
                    TextEditor(text: $bio)
                        .frame(minHeight: 100)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                        .scrollContentBackground(.hidden)
                } else {
                    Text(bio)
                        .font(.body)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // MARK: - Logout Section
    private var logoutSection: some View {
        Button(action: {
            showLogoutConfirmation = true
        }) {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 16, weight: .medium))
                
                Text("Logout")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red.opacity(0.08))
            .cornerRadius(14)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }
    
    // MARK: - Loading Overlay
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                
                Text("Loading...")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.7))
            )
        }
    }
    
    // MARK: - Toast Notification
    private var toastNotification: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 12) {
                Image(systemName: toastMessage.contains("Error") ? "exclamationmark.triangle.fill" :
                      toastMessage.contains("photo") ? "camera.fill" : "checkmark.circle.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 18))
                
                Text(toastMessage)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring()) {
                        showToast = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color.black.opacity(0.9), Color.black.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 5)
            .padding(.horizontal, 20)
            .padding(.bottom, 50)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showToast)
    }
    
    // MARK: - Animation Functions
    private func loadUserProfileWithAnimation() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            headerScale = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                cardOffset = 0
                cardOpacity = 1
            }
        }
        
        loadUserProfile()
    }
    
    private func startEditing() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            isEditing = true
        }
    }
    
    // MARK: - Profile Functions
    private func loadUserProfile() {
        guard !userId.isEmpty else { return }
        
        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                name = data?["name"] as? String ?? userName
                age = "\(data?["age"] as? Int ?? 0)"
                phone = data?["phone"] as? String ?? ""
                location = data?["location"] as? String ?? ""
                occupation = data?["occupation"] as? String ?? ""
                bio = data?["bio"] as? String ?? "Share something about yourself..."
                profileImageUrl = data?["profileImageUrl"] as? String ?? ""
            } else {
                createInitialProfile()
            }
        }
    }
    
    private func createInitialProfile() {
        let userData: [String: Any] = [
            "name": userName,
            "email": userEmail,
            "createdAt": Timestamp(),
            "profileImageUrl": Auth.auth().currentUser?.photoURL?.absoluteString ?? ""
        ]
        
        db.collection("users").document(userId).setData(userData) { error in
            if let error = error {
                showMessage("Error creating profile: \(error.localizedDescription)")
            } else {
                loadUserProfile()
            }
        }
    }
    
    private func saveProfile() {
        isLoading = true
        
        let userData: [String: Any] = [
            "name": name,
            "age": Int(age) ?? 0,
            "phone": phone,
            "location": location,
            "occupation": occupation,
            "bio": bio,
            "profileImageUrl": profileImageUrl,
            "updatedAt": Timestamp()
        ]
        
        db.collection("users").document(userId).setData(userData, merge: true) { error in
            isLoading = false
            if let error = error {
                showMessage("Error: \(error.localizedDescription)")
            } else {
                showMessage("Profile updated successfully! 🎉")
                withAnimation(.spring()) {
                    isEditing = false
                }
            }
        }
    }
    
    private func cancelEditing() {
        withAnimation(.spring()) {
            isEditing = false
        }
        loadUserProfile()
    }
    
    private func refreshProfile() async {
        withAnimation(.spring()) {
            headerScale = 0.95
        }
        
        try? await Task.sleep(nanoseconds: 200_000_000)
        
        loadUserProfile()
        
        withAnimation(.spring()) {
            headerScale = 1.0
        }
        
        showMessage("Profile refreshed! 🔄")
    }
    
    private func handlePhotoSelection(_ newItem: PhotosPickerItem?) async {
        if let data = try? await newItem?.loadTransferable(type: Data.self),
           let image = UIImage(data: data) {
            await MainActor.run {
                profileImage = image
                uploadProfileImage(image: image)
            }
        }
    }
    
    private func uploadProfileImage(image: UIImage) {
        isUploadingImage = true
        
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            showMessage("Error compressing image")
            return
        }
        
        let storageRef = storage.reference()
        let imageRef = storageRef.child("profile_images/\(userId)_\(Date().timeIntervalSince1970).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        imageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                showMessage("Upload error: \(error.localizedDescription)")
                isUploadingImage = false
                return
            }
            
            imageRef.downloadURL { url, error in
                isUploadingImage = false
                if let downloadURL = url {
                    profileImageUrl = downloadURL.absoluteString
                    showMessage("Profile photo updated! 📸")
                    saveProfile()
                }
            }
        }
    }
    
    private func logoutUser() {
        do {
            try Auth.auth().signOut()
        } catch {
            showMessage("Logout error: \(error.localizedDescription)")
        }
    }
    
    private func showMessage(_ message: String) {
        toastMessage = message
        showToast = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            withAnimation(.spring()) {
                showToast = false
            }
        }
    }
}

// MARK: - Supporting Views

struct StatItem: View {
    let value: String
    let title: String
    
    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let isPrimary: Bool
    var isLoading: Bool = false
    
    var body: some View {
        HStack(spacing: 8) {
            if !icon.isEmpty && !isLoading {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
            }
            
            if isLoading {
                ProgressView()
                    .scaleEffect(0.8)
                    .tint(isPrimary ? .white : color)
            }
            
            Text(title)
                .fontWeight(.semibold)
        }
        .foregroundColor(isPrimary ? .white : color)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(isPrimary ? color : color.opacity(0.12))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isPrimary ? Color.clear : color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct PremiumProfileField: View {
    let icon: String
    let title: String
    @Binding var value: String
    let isEditing: Bool
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color(red: 0.1, green: 0.3, blue: 0.8))
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                if isEditing {
                    TextField(placeholder, text: $value)
                        .font(.body)
                        .foregroundColor(.primary)
                        .keyboardType(keyboardType)
                } else {
                    if value.isEmpty {
                        Text(placeholder)
                            .font(.body)
                            .foregroundColor(.gray.opacity(0.7))
                            .italic()
                    } else {
                        Text(value)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(isEditing ? Color(.systemGray6).opacity(0.6) : Color.clear)
        .cornerRadius(12)
        .padding(.horizontal, 4)
    }
}
