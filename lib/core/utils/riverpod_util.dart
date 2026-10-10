Duration? fixedRetry(int retryCount, Object error) {
  if (retryCount >= 3) return null; // maksimal 3 kali coba ulang
  // Total: 2 + 2 + 2 = 6 detik
  return const Duration(seconds: 2); // tiap jeda 2 detik
}
