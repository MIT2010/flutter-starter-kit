#!/bin/bash
# ================================================================
# Generate fitur baru dengan clean architecture + BLoC
# Usage: ./tools/scripts/generate_feature.sh <nama_fitur>
# Contoh: ./tools/scripts/generate_feature.sh product
# ================================================================

# Di Git Bash (Windows), `dart pub global activate` membuat shim
# "mason.bat" — bare "mason" sering tidak ke-resolve lewat PATH meski
# foldernya ada di PATH. Fallback ke "mason.bat" kalau bare tidak ada.
MASON_BIN="mason"
if ! command -v mason &> /dev/null && command -v mason.bat &> /dev/null; then
  MASON_BIN="mason.bat"
fi

FEATURE_NAME=$1

if [ -z "$FEATURE_NAME" ]; then
  read -p "Nama fitur baru (snake_case, contoh: product): " FEATURE_NAME
fi

if [ -z "$FEATURE_NAME" ]; then
  echo ""
  echo "❌ Error: Nama fitur diperlukan"
  echo "Usage: ./tools/scripts/generate_feature.sh <nama_fitur>"
  echo ""
  exit 1
fi

FEATURE_DIR="packages/features/feature_${FEATURE_NAME}"

if [ -d "$FEATURE_DIR" ]; then
  echo ""
  echo "❌ Error: Feature '$FEATURE_NAME' sudah ada di $FEATURE_DIR"
  echo ""
  exit 1
fi

echo ""
echo "✨ Generate fitur baru: $FEATURE_NAME"
echo ""

# Tulis variabel brick ke file JSON sementara — versi mason_cli yang
# dipakai starter kit ini tidak mengenali flag "--name" langsung,
# variabel brick harus dilewatkan lewat --config-path.
MASON_VARS_FILE=$(mktemp)
echo "{\"name\": \"$FEATURE_NAME\"}" > "$MASON_VARS_FILE"

cd tools/mason
"$MASON_BIN" get
"$MASON_BIN" make feature_brick \
  --config-path "$MASON_VARS_FILE" \
  --output-dir "../../$FEATURE_DIR" \
  --on-conflict overwrite
cd ../..
rm -f "$MASON_VARS_FILE"

echo ""
echo "✅ Fitur berhasil digenerate di: $FEATURE_DIR/"
echo ""
echo "📋 Langkah selanjutnya:"
echo "  1. Daftarkan ke workspace root pubspec.yaml:"
echo "       - packages/features/feature_${FEATURE_NAME}"
echo "  2. Daftarkan sebagai dependency di apps/main/pubspec.yaml (atau app lain yang memakainya)"
echo "  3. Implementasi data layer (models/, datasources/, repositories/)"
echo "  4. Register DI di core/di/injection.dart"
echo "  5. Tambahkan route di core/router/app_router.dart"
echo "  6. dart pub get lalu melos run gen"
echo "  7. Generate test scaffold: ./tools/scripts/generate_test.sh ${FEATURE_NAME}"
echo ""
