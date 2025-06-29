import sys
import os

print(f"🐍 Python Executable: {sys.executable}")
print(f"🐍 Python Version: {sys.version}")

print("\n* sys.path:")
for p in sys.path:
    print(f"  - {p}")

# 가상 환경 경로 확인
venv_path = os.path.abspath('venv')
print(f"\n* Expected venv path: {venv_path}")

try:
    import roboflow
    print("\n✅ Successfully imported 'roboflow' module.")
    print(f"   Location: {roboflow.__file__}")
except ImportError as e:
    print(f"\n❌ Failed to import 'roboflow': {e}")
except Exception as e:
    print(f"\n🔥 An unexpected error occurred: {e}")
