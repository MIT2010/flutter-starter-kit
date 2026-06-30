#!/bin/bash
# ================================================================
# Generate unit test untuk feature yang sudah ada
# Usage: ./tools/scripts/generate_test.sh <nama_fitur>
# Contoh: ./tools/scripts/generate_test.sh product
# ================================================================

FEATURE_NAME=$1

if [ -z "$FEATURE_NAME" ]; then
  echo ""
  echo "❌ Error: Nama fitur diperlukan"
  echo "Usage: ./tools/scripts/generate_test.sh <nama_fitur>"
  echo ""
  exit 1
fi

FEATURE_DIR="packages/features/feature_${FEATURE_NAME}"

if [ ! -d "$FEATURE_DIR" ]; then
  echo ""
  echo "❌ Error: Feature '$FEATURE_NAME' tidak ditemukan"
  echo "Pastikan folder '$FEATURE_DIR' sudah ada"
  echo ""
  exit 1
fi

echo ""
echo "🧪 Generate test untuk feature: $FEATURE_NAME"
echo ""

# Buat folder test/unit jika belum ada
mkdir -p "$FEATURE_DIR/test/unit"

# Generate dengan Mason — biarkan Mason prompt interaktif untuk usecases
cd tools/mason
mason make test_brick \
  --name "$FEATURE_NAME" \
  --output-dir "../../$FEATURE_DIR" \
  --on-conflict overwrite

echo ""
echo "✅ Test berhasil digenerate di: $FEATURE_DIR/test/unit/"
echo ""
echo "📋 Langkah selanjutnya:"
echo "  1. Buka file test yang digenerate"
echo "  2. Lengkapi field TODO sesuai entity dan use case kamu"
echo "  3. Jalankan build_runner untuk generate mock:"
echo "     cd $FEATURE_DIR && dart run build_runner build"
echo "  4. Jalankan test:"
echo "     cd $FEATURE_DIR && flutter test test/unit/"
echo ""
