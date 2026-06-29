#!/bin/bash
echo "Menyiapkan environment Flutter di Vercel..."

# Clone Flutter SDK versi stable
git clone https://github.com/flutter/flutter.git -b stable --depth 1

# Tambahkan Flutter ke PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Enable web dan build
flutter config --enable-web
flutter build web --release
