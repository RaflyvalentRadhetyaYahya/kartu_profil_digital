class ProfileData {
  final String name;
  final String title;
  final String bio;

  const ProfileData({
    required this.name,
    required this.title,
    required this.bio,
  });

  /// Data bawaan saat belum ada data tersimpan.
  static const defaults = ProfileData(
    name: 'Rafly Valent',
    title: 'Software Engineer & Dosen',
    bio: 'Suka membangun aplikasi mobile dan berbagi ilmu.',
  );
}