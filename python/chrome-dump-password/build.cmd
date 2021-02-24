pip install pyinstaller
pyinstaller --onefile main.py
del /Q /F /S __pycache__ build main.spec

